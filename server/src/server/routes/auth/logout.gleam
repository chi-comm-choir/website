import gleam/erlang/process.{type Subject}
import gleam/json
import server/routes/cache/session_cache.{type CacheMessage}
import wisp.{type Request, type Response}

pub fn logout(req: Request, cache_subject: Subject(CacheMessage)) -> Response {
  case wisp.get_cookie(req, "lf_session_token", wisp.PlainText) {
    Ok(token) -> session_cache.cache_remove(cache_subject, token)
    Error(_) -> Nil
  }

  wisp.json_response(
    json.object([#("message", json.string("Logged out"))])
      |> json.to_string_tree,
    200,
  )
  |> wisp.set_cookie(
    req,
    "lf_session_token",
    "",
    wisp.PlainText,
    60 * 60 * 24 * 1000,
  )
}
