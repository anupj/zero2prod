FROM lukemathwalker/cargo-chef:latest-rust-1.63.0 as chef
# Let's switch our working directory to `app` (equivalent to `cd app`)
# The `app` folder will be created for us by Docker in case it does
# not exist already
WORKDIR /app
# Install the required system dependencies for our linking configuration
RUN apt update && apt install lld clang -y


FROM chef as planner
# Copy all files from our working environment to our Docker image
COPY . .
# Compute a lock-like file for our project
RUN cargo chef prepare --recipe-path recipe.json

FROM chef as builder
COPY --from=planner /app/recipe.json recipe.json
# Build our project dependencies, not our application!
RUN cargo chef cook  --release --recipe-path recipe.json
# Up to this point, if our dependency tree stays the same,
# all layers should be cached.
COPY . .
ENV SQLX_OFFLINE true

# Let's build our binary
# We'll use the release profile to make it faaast
RUN cargo build --release --bin zero2prod

# Runtime stage
FROM debian:bullseye-slim AS runtime

WORKDIR /app

# Install OpenSSL - it is dynamically linked by some of 
# our dependencies
# Install ca-certificates - it is needed to verify TLS certificates
# when establishing HTPPS connections
RUN apt-get update -y \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  # Clean up
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*
# Copy the compiled binary from the builder environment
# to our runtime environment
COPY --from=builder /app/target/release/zero2prod zero2prod
# We need a configuration file at runtime!
COPY configuration configuration
# Set the environment variable - app_environment
ENV APP_ENVIRONMENT production

# When `docker run` is executed, launch the binary!
ENTRYPOINT [ "./zero2prod" ]
