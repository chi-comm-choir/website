import gleam/http.{Get}
import gleam/int
import gleam/io
import gleam/json
import gleam/result
import server/db/user_session
import server/response
import wisp.{type Request, type Response}
import gleam/erlang/process.{type Subject}
import server/routes/cache/session_cache.{type CacheMessage}


pub fn validate(req: Request, cache_subject: Subject(CacheMessage)) -> Response {
  case req.method {
    Get -> validate_session(req, cache_subject)
    // Post -> create_comment(req)
    _ -> wisp.method_not_allowed([Get])
  }
}

fn validate_session(req: Request, cache_subject: Subject(CacheMessage)) -> Response {
  io.println("running validate_session")
  // TODO: Check if the cache call is get_user_from_session is enough
  let result = {
    use #(user_id, is_admin_int) <- result.try(user_session.get_user_from_session(req, cache_subject))
    io.println("id:" <> int.to_string(user_id))
    let is_admin = case is_admin_int {
      1 -> True
      _ -> False
    }

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
