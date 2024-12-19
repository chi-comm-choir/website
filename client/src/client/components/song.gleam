import client/lib/msg.{type Msg}
import lustre/element.{type Element}
import lustre/element/html
import shared.{type Song}

pub fn song(song: Song) -> Element(Msg) {
  html.div([], [html.p([], [element.text(song.title)])])
}
