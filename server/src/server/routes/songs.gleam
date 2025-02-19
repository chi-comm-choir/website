import cake/insert
import cake/select
import cake/where
import gleam/bool
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/http.{Get, Post}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import server/db
import server/db/song
import server/response
import shared
import sqlight
import wisp.{type Request, type Response}

pub fn songs(req: Request) -> Response {
  case req.method {
    Get -> list_songs_res(req)
    Post -> create_song(req)
    _ -> wisp.method_not_allowed([Get, Post])
  }
}

pub fn list_songs(req: Request) -> Result(List(shared.Song), String) {
  case
    song.get_songs_query()
    |> song.run_song_query([])
  {
    Ok(rows) -> Ok(song.song_rows_to_song(req, rows))
    Error(_) -> Error("Selecting songs")
  }
}

pub fn list_songs_res(req: Request) -> Response {
  let query = case song.get_songs_query() |> song.run_song_query([]) {
    Ok(rows) -> Ok(rows)
    Error(_) -> Error("Selecting songs")
  }

  case query {
    Ok(rows) ->
      Ok(
        json.object([
          #(
            "songs",
            song.song_rows_to_song(req, rows)
              |> json.array(fn(song) { song.song_to_json(song) }),
          ),
        ])
        |> json.to_string_tree,
      )
    Error(error) -> Error(error)
  }
  |> response.generate_wisp_response
}

type CreateSong {
  CreateSong(
    title: String,
    href: Option(String),
    filepath: Option(String),
    tags: List(Int),
  )
}

fn decode_create_song(json: Dynamic) -> Result(CreateSong, List(decode.DecodeError)) {
  let decoder = {
    use title <- decode.field("title", decode.string)
    use href <- decode.field("href", decode.optional(decode.string))
    use filepath <- decode.field("filepath", decode.optional(decode.string))
    use tags <- decode.field("tags", decode.list(decode.int))
    decode.success(CreateSong(title, href, filepath, tags))
  }
  decode.run(json, decoder)
}

fn insert_song_to_db(_req: Request, song: CreateSong) {
  let _ =
    [
      insert.row([
        insert.string(song.title),
        case song.href {
          Some(href) -> insert.string(href)
          None ->
            case song.filepath {
              Some(filepath) -> insert.string(filepath)
              None -> panic as "Unreachable due to guard"
            }
        },
      ]),
    ]
    |> insert.from_values(table_name: "song", columns: [
      "title",
      case song.href {
        Some(_) -> "href"
        None ->
          case song.filepath {
            Some(_) -> "filepath"
            None -> panic as "Unreachable due to guard"
          }
      },
    ])
    |> insert.to_query
    |> db.execute_write([
      sqlight.text(song.title),
      sqlight.text(case song.href {
        Some(href) -> href
        None ->
          case song.filepath {
            Some(filepath) -> filepath
            None -> panic as "Unreachable due to guard"
          }
      }),
    ])

  Ok(Nil)
}

fn does_song_with_href_exist(song: CreateSong) {
  use <- bool.guard(
    when: case song.href {
      Some(_) -> False
      None -> True
    },
    return: Ok(False),
  )

  case
    select.new()
    |> select.selects([select.col("song.title"), select.col("song.href")])
    |> select.from_table("song")
    |> select.where(
      where.or([
        case song.href {
          Some(href) -> where.eq(where.col("song.href"), where.string(href))
          None -> panic as "Unreachable due to guard"
        },
      ]),
    )
    |> select.to_query
    |> db.execute_read(
      [
        sqlight.text(case song.href {
          Some(href) -> href
          None -> panic as "Unreachable due to guard"
        }),
      ],
      {
        use str1 <- decode.field(0, decode.string)
        use str2 <- decode.field(1, decode.string)
        decode.success(#(str1, str2))
      }
    )
  {
    Ok(songs) -> Ok(list.length(songs) > 0)
    Error(_) -> Error("Problem selecting songs with same href")
  }
}

pub fn create_song(req: Request) -> Response {
  use body <- wisp.require_json(req)

  let result = {
    use song <- result.try(case decode_create_song(body) {
      Ok(val) -> Ok(val)
      Error(_) -> Error("Invalid request body received")
    })

    use <- bool.guard(
      when: case song.href {
        Some(_) -> False
        None ->
          case song.filepath {
            Some(_) -> False
            None -> True
          }
      },
      return: Error("Neither href nor filepathn provided"),
    )

    use <- bool.guard(
      when: song.title == "",
      return: Error("No title provided"),
    )

    use song_with_href_exists <- result.try(does_song_with_href_exist(song))

    use <- bool.guard(
      when: song_with_href_exists,
      return: Error("Song with the same link already exists"),
    )

    use <- bool.guard(
      when: {
        case song.href {
          Some(href) -> {
            let assert Ok(re) =
              regexp.from_string(
                "[-a-zA-Z0-9@:%._\\+~#=]{1.256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\*.~#?&//=]*)",
              )
            !regexp.check(re, href)
          }
          None -> False
        }
      },
      return: Error("Invalid url provided"),
    )

    use _ <- result.try(case insert_song_to_db(req, song) {
      Ok(_) -> Ok(Nil)
      Error(_) -> Error("Problem creating song")
    })

    Ok(
      json.object([#("message", json.string("Created song"))])
      |> json.to_string_tree,
    )
  }

  response.generate_wisp_response(result)
}
