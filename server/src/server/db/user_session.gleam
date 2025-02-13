import cake/insert
import cake/select
import cake/where
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/result
import server/db
import server/token.{generate_token}
import sqlight
import wisp.{type Request}
import gleam/erlang/process.{type Subject}
import server/routes/cache/session_cache.{type CacheMessage, CacheEntry}
import gleam/option.{Some, None}
import gleam/bool

pub fn get_user_from_session(
  req: Request,
  cache_subject: Subject(CacheMessage)
) -> Result(#(Int, Int), String) {
  io.println("getting user id from session")
  let result = {
  use req_session_token <- result.try(
    wisp.get_cookie(req, "lf_session_token", wisp.PlainText)
    |> result.replace_error("No session cookie found")
  )

  case session_cache.cache_get(cache_subject, req_session_token) {
      Some(CacheEntry(id, is_admin, _)) -> {
        io.println("Got user from cache")
        Ok(#(id, bool.to_int(is_admin)))
      }
      None -> {

  let session_token_result = case
    select.new()
    |> select.selects([
      select.col("user_session.id"),
      select.col("user_session.is_admin"),
    ])
    |> select.from_table("user_session")
    |> select.where(where.eq(
      where.col("user_session.token"),
      where.string(req_session_token),
    ))
    |> select.to_query
    |> db.execute_read(
      [sqlight.text(req_session_token)],
      dynamic.tuple2(dynamic.int, dynamic.int) // decoder
    )
  {
    Ok(users) -> Ok(list.first(users))
    Error(e) -> {
      Error("Problem getting user_session by token: " <> e.message <> " -- with token: " <> req_session_token)
    }
  }

  use user_id_result <- result.try(session_token_result)
  case user_id_result {
    Ok(id) -> Ok(id)
    Error(_) ->
      Error("No user_session found when getting user_session by token")
  }
  }}}
  io.println("result: " <> result.unwrap_error(result, "user id obtained from session."))
  result
}

pub fn create_user_session(is_admin: Bool, cache_subject: Subject(CacheMessage)) {
  let token = generate_token(64)

  let result =
    [insert.row([insert.string(token), insert.bool(is_admin)])]
    |> insert.from_values(table_name: "user_session", columns: ["token", "is_admin"])
    |> insert.to_query
    |> db.execute_write([sqlight.text(token), sqlight.bool(is_admin)])

  case result {
    Ok(ids) -> {
      case list.first(ids) {
        Ok(id) -> {
          io.println("adding user to cache")
          session_cache.cache_put(cache_subject, token, id, is_admin)
        }
        Error(_) -> io.println("warning, no id, cache not written")
      }
      Ok(token)
    }
    Error(err) -> Error("Creating user session:" <> err.message <> " -- with token: " <> token)
  }
}
