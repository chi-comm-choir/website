import cake.{type ReadQuery}
import cake/dialect/sqlite_dialect
import gleam/dynamic.{type Dynamic}
import gleam/option.{Some}
import sqlight.{type Connection, type Value}

pub fn execute_read(
  read_query: ReadQuery,
  params: List(Value),
  decoder: fn(Dynamic) -> Result(a, List(dynamic.DecodeError)),
) {
  let prepared_statement =
    read_query
    |> sqlite_dialect.read_query_to_prepared_statement
    |> cake.get_sql

  use conn <- sqlight.with_connection("file:songs.db?mode=memory")
  sqlight.query(prepared_statement, conn, params, decoder)
}

@external(erlang, "erlang", "list_to_tuple")
pub fn list_to_tuple(dynamic: Dynamic) -> Dynamic
