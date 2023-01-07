use std::fmt::{Debug, Display};
use tokio::task::JoinError;
use zero2prod::configuration::get_configuration;
use zero2prod::issue_delivery_worker::run_worker_until_stopped;
use zero2prod::startup::Application;
use zero2prod::telemetry::{get_subscriber, init_subscriber};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // `Subscriber` Trait representing the functions required to collect trace data.
    // This subscriber has nothing to do with our email newsletter subscriber
    let subscriber =
        get_subscriber("zero2prod".into(), "info".into(), std::io::stdout);
    init_subscriber(subscriber);

    // Panic if we can't read configuration
    let configuration =
        get_configuration().expect("Failed to read configuration.");

    // Run the API application
    let application = Application::build(configuration.clone()).await?;
    // spawn a `tokio` task
    let application_task = tokio::spawn(application.run_until_stopped());

    // Run the background worker for processing
    // the newsletters from the queue
    // by spawning it as a `tokio` task
    let worker_task = tokio::spawn(run_worker_until_stopped(configuration));

    // `tokio::select!` will run these tasks concurrently
    // and will return as soon as one of the two tasks completes
    // or errors out.
    tokio::select! {
        o = application_task => report_exit("API", o),
        o = worker_task => report_exit("Background worker", o),
    };

    Ok(())
}

fn report_exit(
    task_name: &str,
    outcome: Result<Result<(), impl Debug + Display>, JoinError>,
) {
    match outcome {
        Ok(Ok(())) => {
            tracing::info!("{} has exited", task_name)
        }
        Ok(Err(e)) => {
            tracing::error!(
            error.cause_chain = ?e,
            error.message = %e,
            "{} failed",
            task_name
            )
        }

        Err(e) => {
            tracing::error!(
            error.cause_chain = ?e,
            error.message = %e,
            "{} task failed to complete",
            task_name
            )
        }
    }
}
