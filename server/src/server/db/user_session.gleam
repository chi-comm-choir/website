import cake/insert
import cake/select
import cake/where
import gleam/dynamic
import gleam/io
import gleam/list
import gleam/result
import server/db
import server/token.{generate_token}
import shared.{type AuthUser, AuthUser}
import sqlight
import wisp.{type Request}

pub fn get_user_priviledges_from_session(
  req: Request,
) -> Result(AuthUser, String) {
  use session_token <- result.try(
    wisp.get_cookie(req, "lf_session_token", wisp.PlainText)
    |> result.replace_error("No session cookie found"),
  )

  let session_token = case
    select.new()
    |> select.selects([
      select.col("user_session.id"),
      select.col("user_session.priviledges"),
    ])
    |> select.from_table("user_session")
    |> select.where(where.eq(
      where.col("user_session.token"),
      where.string(session_token),
    ))
    |> select.to_query
    |> db.execute_read(
      [sqlight.text(session_token)],
      dynamic.tuple2(dynamic.int, dynamic.string),
    )
  {
    Ok(users) -> Ok(list.first(users))
    Error(err) -> {
      io.debug(err)
      Error("Problem getting user_session by token")
    }
  }

  use user_priviledges_result <- result.try(session_token)
  case user_priviledges_result {
    Ok(priviledges) ->
      case priviledges.1 {
        "admin" -> Ok(AuthUser(True))
        "member" -> Ok(AuthUser(False))
        _ -> Error("Invalid user priviledge level")
      }
    Error(_) ->
      Error("No user_session found when getting user_session by token")
  }
}

pub fn create_user_session(user_id: Int) {
  let token = generate_token(64)

  let result =
    [insert.row([insert.int(user_id), insert.string(token)])]
    |> insert.from_values(table_name: "user_session", columns: [
      "user_id", "token",
    ])
    |> insert.to_query
    |> db.execute_write([sqlight.int(user_id), sqlight.text(token)])

  case result {
    Ok(_) -> Ok(token)
    Error(_) -> Error("Creating user session")
  }
}
