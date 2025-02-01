import cake.{type ReadQuery, type WriteQuery}
import cake/dialect/sqlite_dialect
import gleam/dynamic.{type Dynamic}
import sqlight.{type Value}

import gleam/io

pub fn execute_read(
  read_query: ReadQuery,
  params: List(Value),
  decoder: fn(Dynamic) -> Result(a, List(dynamic.DecodeError)),
) {
  let prepared_statement =
    read_query
    |> sqlite_dialect.read_query_to_prepared_statement
    |> cake.get_sql

  io.println(prepared_statement)

  use conn <- sqlight.with_connection("file:lfs.db")
  sqlight.query(prepared_statement, conn, params, decoder)
}

pub fn execute_write(
  write_query: WriteQuery(a),
  _params: List(Value),
  // unsure if i need these
) {
  let prepared_statement =
    write_query
    |> sqlite_dialect.write_query_to_prepared_statement
    |> cake.get_sql

  use conn <- sqlight.with_connection("file:lfs.db")
  sqlight.exec(prepared_statement, conn)
}

@external(erlang, "erlang", "list_to_tuple")
pub fn list_to_tuple(dynamic: Dynamic) -> Dynamic

pub fn init() {
  use conn <- sqlight.with_connection("file:lfs.db")
  // let decoder = dynamic.tuple2(dynamic.int, dynamic.string)

  let assert Ok(Nil) =
  "
    create table if not exists user_session (id integer primary key, token varchar(255) not null unique);
  "
  |> sqlight.exec(conn)
}
