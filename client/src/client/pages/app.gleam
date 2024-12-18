import client/components/navbar
import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import client/lib/route.{About, Index, NotFound, Songs}
import client/pages/about
import client/pages/index
import client/pages/notfound
import client/pages/songs
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn app(model: Model) -> Element(Msg) {
  html.div([], [
    navbar.navbar(model),
    // Routing
    html.div(
      [
        attribute.style([
          #("width", "full"),
          #("margin", "0 auto"),
          #("padding", "2rem"),
        ]),
      ],
      [
        case model.route {
          Index -> index.index(model)
          About -> about.about(model)
          Songs -> songs.songs(model)
          NotFound -> notfound.notfound(model)
        },
      ],
    ),
  ])
}
