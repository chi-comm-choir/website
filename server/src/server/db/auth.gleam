import cake/select
import cake/where
import gleam/dynamic/decode
import gleam/list
import gleam/result
import server/db
import sqlight

pub type User {
  User(id: Int, is_admin: Bool)
}

fn get_user_base_query() {
  select.new()
  |> select.selects([
    select.col("user_session.id"),
    select.col("user_session.is_admin"),
  ])
  |> select.from_table("user_session")
}

fn user_db_decoder() {
    use id <- decode.field(0, decode.int)
    use is_admin <- decode.field(1, decode.bool)
    decode.success(User(id, is_admin))
}

pub fn get_user_by_id(user_id: Int) -> Result(User, String) {
  let user = case
    get_user_base_query()
    |> select.where(where.eq(where.col("user_session.id"), where.int(user_id)))
    |> select.to_query
    |> db.execute_read([sqlight.int(user_id)], user_db_decoder())
  {
    Ok(users) -> Ok(list.first(users))
    Error(e) -> Error("Problem getting user_session by id: " <> e.message)
  }

  use user_result <- result.try(user)
  case user_result {
    Ok(user) -> Ok(user)
    Error(_) -> Error("No user found when getting user by id")
  }
}

type UserAdmin {
  UserAdmin(id: Int, user_id: Int)
}

pub fn is_user_admin(user_id: Int) -> Bool {
  let result =
    select.new()
    |> select.select(select.col("user_session.id"))
    |> select.from_table("user_session")
    |> select.where(where.eq(where.col("user_session.id"), where.int(user_id)))
    |> select.to_query
    |> db.execute_read([sqlight.int(user_id)],
      {
      use id <- decode.field(0, decode.int)
      use _token <- decode.field(1, decode.int)
      decode.success(UserAdmin(id, user_id))
      }
    )

  case result {
    Ok(result) -> {
      case list.first(result) {
        Ok(_) -> True
        Error(_) -> False
      }
    }
    Error(_) -> False
  }
}
