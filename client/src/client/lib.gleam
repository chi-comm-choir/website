import gleam/uri
import client/lib/route.{type Route, NotFound, Index}

@external(javascript, "../ffi.mjs", "get_route")
fn do_get_route() -> String

pub fn get_route() -> Route {
  let assert Ok(uri) = do_get_route() |> uri.parse

  case uri.path |> uri.path_segments {
    [] -> Index
    _ -> NotFound
  }
}

@external(javascript, "../ffi.mjs", "set_url")
pub fn set_url(url: String) -> String
