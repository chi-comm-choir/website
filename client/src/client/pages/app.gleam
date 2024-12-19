import client/components/navbar
import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import client/lib/route.{Active, NotFound}
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
          // pages
          Active -> songs.songs(model)
          //  TODO: Uhh how does routing work actually
          _ -> notfound.notfound(model)
        },
      ],
    ),
  ])
}
