import gleam/string
import prng/random
import prng/seed

fn do_generate_token(length: Int, result: String, counter: Int) -> String {
  let characters =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  let characters_length = string.length(characters)
  case counter {
    val if val < length -> {
      do_generate_token(
        length,
        result
          <> string.slice(
          characters,
          random.int(0, characters_length) |> random.sample(seed.random()),
          1,
        ),
        counter + 1,
      )
    }
    _ -> result
  }
}

pub fn generate_token(length: Int) -> String {
  do_generate_token(length, "", 0)
}
