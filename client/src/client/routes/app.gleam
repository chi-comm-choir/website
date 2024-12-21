import client/components/navbar
import client/lib/model.{type Model}
import client/lib/msg.{type Msg}
import client/lib/route.{
  About, CreateSong, Index, Login, NotFound, ShowSong, Songs,
}
import client/routes/about
import client/routes/auth
import client/routes/index
import client/routes/songs
import gleam/option.{Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/ui/styles

pub fn app(model: Model) -> Element(Msg) {
  html.div([], [
    styles.elements(),
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
        case model.route, model.auth_user {
          // pages
          Index, _ -> index.index(model)
          About, _ -> about.about(model)
          Songs, _ -> songs.songs(model)
          Login, _ -> auth.login(model)
          CreateSong, Some(_) -> songs.create_song(model)
          ShowSong(_), _ -> songs.show_song(model)
          NotFound, _ -> element.text("404 not found")
          _, _ -> element.text("404 not found")
        },
      ],
    ),
  ])
}
