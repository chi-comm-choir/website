import argv
import gleam/erlang/process
import gleam/int
import mist
import server/router
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()

  let assert #(host, Ok(port)) = case argv.load().arguments {
    ["--host", h, "--port", p] -> #(h, int.parse(p))
    ["--host", h] -> #(h, Ok(8080))
    ["--port", p] -> #("localhost", int.parse(p))
    _ -> #("127.0.0.1", Ok(8080))
  }

  let secret_key_base = "server"
  let assert Ok(_) =
    router.handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind(host)
    |> mist.port(port)
    |> mist.start_http
  process.sleep_forever()
}
