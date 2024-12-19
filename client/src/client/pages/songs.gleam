import client/components/song
import client/lib/model.{type Model}
import gleam/list
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/ui/classes

pub fn songs(model: Model) {
  html.div([], [
    html.div(
      [attribute.style([#("display", "flex"), #("justify-content", "center")])],
      [html.p([classes.font_alt()], [element.text("Songs")])],
    ),
    html.div(
      [
        attribute.style([
          #("display", "flex"),
          #("flex-direction", "columns"),
          #("justify-content", "center"),
        ]),
      ],
      case model.songs {
        [] -> [element.text("no songs found")]
        songs -> list.map(songs, song.song)
      },
    ),
  ])
}
