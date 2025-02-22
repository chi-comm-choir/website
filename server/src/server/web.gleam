import wisp

pub fn middleware(
  req: wisp.Request,
  handle_request: fn(wisp.Request) -> wisp.Response,
) -> wisp.Response {
  // Permit browsers to simulate methods other than GET and POST using the
  // `_method` query parameter.
  let req = wisp.method_override(req)

  // Log information about the request and response.
  use <- wisp.log_request(req)

  // Return a default 500 response if the request handler crashes.
  use <- wisp.rescue_crashes

  // Rewrite HEAD requests to GET requests and return an empty body.
  use req <- wisp.handle_head(req)

  // Serve build output site files
  let assert Ok(priv_directory) = wisp.priv_directory("server")
  use <- wisp.serve_static(
    req,
    under: "/static",
    from: priv_directory <> "/static",
  )

  // Handle the request!
  handle_request(req)
}
