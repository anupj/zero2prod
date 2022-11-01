use actix_web::HttpResponse;

/// We were returning `impl Responder` at the very beginning.
/// We are now spelling out the type explicitly given that we have
/// become more familiar with `actix-web`.
/// There is no performance difference! Just a stylistic choice :)
pub async fn health_check() -> HttpResponse {
    HttpResponse::Ok().finish()
}
