import cake/select
import cake/where
import decode
import gleam/list
import gleam/result
import sqlight
import server/db

pub type User {
  User(
    id: Int,
  )
}

fn get_user_base_query() {
  select.new()
  |> select.selects([
    select.col("user.id")
  ])
  |> select.from_table("user")
}

fn user_db_decoder() {
  fn(data) {
    decode.into({
      use id <- decode.parameter
      User(id)
    })
    |> decode.field(0, decode.int)
    |> decode.from(data |> db.list_to_tuple)
  }
}

pub fn get_user_by_id(user_id: Int) -> Result(User, String) {
  let user = case get_user_base_query()
  |> select.where(where.eq(where.col("user.id"), where.int(user_id)))
  |> select.to_query
  |> db.execute_read([sqlight.int(user_id)], user_db_decoder())
  {
    Ok(users) -> Ok(list.first(users))
    Error(e) -> Error("Problem getting user by id: " <> e.message)
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
  let result = select.new()
  |> select.selects([select.col("user_admin.id"), select.col("user_admin.user_id")])
  |> select.from_table("user_admin")
  |> select.where(where.eq(where.col("user_admin.user_id"), where.int(user_id)))
  |> select.to_query
  |> db.execute_read([sqlight.int(user_id)], fn(data) {
    decode.into({
      use id <- decode.parameter
      use user_id <- decode.parameter
      UserAdmin(id, user_id)
    })
    |> decode.field(0, decode.int)
    |> decode.field(1, decode.int)
    |> decode.from(data)
  })

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
