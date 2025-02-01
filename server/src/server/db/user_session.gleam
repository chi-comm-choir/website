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

pub fn get_user_id_from_session(
  req: Request,
) -> Result(Int, String) {
  io.println("getting user id from session")
  let foo = {
  use req_session_token <- result.try(
    wisp.get_cookie(req, "lf_session_token", wisp.PlainText)
    |> result.replace_error("No session cookie found")
  )

  io.println("req_session_token: " <> req_session_token)

  let session_token_result = case
    select.new()
    |> select.select(
      select.col("user_session.id"),
    )
    |> select.from_table("user_session")
    |> select.where(where.eq(
      where.col("user_session.token"),
      where.string(req_session_token),
    ))
    |> select.to_query
    |> db.execute_read(
      [sqlight.text(req_session_token)],
      dynamic.element(0, dynamic.int) // decoder
    )
  {
    Ok(users) -> Ok(list.first(users))
    Error(e) -> {
      Error("Problem getting user_session by token: " <> e.message)
    }
  }

  use user_id_result <- result.try(session_token_result)
  case user_id_result {
    Ok(id) -> Ok(id)
    Error(_) ->
      Error("No user_session found when getting user_session by token")
  }
  }
  io.println(result.unwrap_error(foo, "idk!"))
  foo
}

pub fn create_user_session() {
  let token = generate_token(64)
  io.println("create user session: " <> token)

  let result =
    [insert.row([insert.string(token)])]
    |> insert.from_values(table_name: "user_session", columns: [
      "token",
    ])
    |> insert.to_query
    |> db.execute_write([sqlight.text(token)])

  case result {
    Ok(_) -> Ok(token)
    Error(err) -> Error("Creating user session:" <> err.message)
  }
}
