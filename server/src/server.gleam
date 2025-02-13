import argv
import gleam/erlang/process
import gleam/otp/supervisor
import gleam/int
import mist
import server/router
import server/db
import wisp
import wisp/wisp_mist
import server/routes/cache/session_cache
import gleam/dict

pub fn main() {
  wisp.configure_logger()

  let assert #(host, Ok(port)) = case argv.load().arguments {
    ["--host", h, "--port", p] -> #(h, int.parse(p))
    ["--host", h] -> #(h, Ok(8080))
    ["--port", p] -> #("localhost", int.parse(p))
    _ -> #("127.0.0.1", Ok(8080))
  }

  let parent_subject = process.new_subject()
  let cache = supervisor.worker(session_cache.start_cache(_, parent_subject))
  // let cache_cleaner = supervisor.worker(session_cache.cache_cleaner(_, parent_subject))
  // let assert Ok(_supervisor_subject) = supervisor.start(supervisor.add(_, cache))
  let assert Ok(_supervisor_subject) = supervisor.start_spec(supervisor.Spec(
    argument: dict.new(),
    frequency_period: 1,
    max_frequency: 5,
    init: supervisor.add(_, cache),
  ))
  let assert Ok(cache_subject) = process.receive(parent_subject, 1000)

  let _ = db.init()

  let secret_key_base = "serversnateiostneiarntsieonatieosntanrsietnearntiesnraieontsor"
  let assert Ok(_) =
    router.handle_request(_, cache_subject)
    |> wisp_mist.handler(secret_key_base)
    |> mist.new
    |> mist.bind(host)
    |> mist.port(port)
    |> mist.start_http
  process.sleep_forever()
}
