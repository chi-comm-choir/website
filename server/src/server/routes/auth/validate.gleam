import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import server/db/auth
import server/db/user_session
import server/response
import wisp.{type Request, type Response}

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
    use user_id <- result.try(user_session.get_user_id_from_session(req))
    io.println("id:" <> int.to_string(user_id.1))

    use user <- result.try(auth.get_user_by_id(user_id.1))

    let is_admin = auth.is_user_admin(user.id)

    Ok(
      json.object([
        #("user_id", json.int(user_id.1)),
        #("is_admin", json.bool(is_admin)),
      ])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
