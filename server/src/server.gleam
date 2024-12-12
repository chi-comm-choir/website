import gleam/erlang/process
import mist
import server/router
import wisp
import wisp/wisp_mist

pub fn main() {
  wisp.configure_logger()
  let secret_key_base = ""
  let assert Ok(_) =
    router.handle_request
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(8080)
    |> mist.start_http
  process.sleep_forever()
}
