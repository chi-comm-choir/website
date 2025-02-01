import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import server/db/auth
import server/db/user_session
import server/response
import wisp.{type Request, type Response}

import gleam/bool

pub fn validate(req: Request) -> Response {
  case req.method {
    Get -> validate_session(req)
    // Post -> create_comment(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn validate_session(req: Request) -> Response {
  io.println("running validate_session")
  let result = {
    use #(user_id, is_admin) <- result.try(user_session.get_user_from_session(req))
    io.println("id:" <> int.to_string(user_id))
    io.println("is_admin:" <> bool.to_string(is_admin))


    Ok(
      json.object([
        #("user_id", json.int(user_id)),
        #("is_admin", json.bool(is_admin)),
      ])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
