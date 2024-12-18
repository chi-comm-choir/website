import client/lib/route.{type Route}
import shared.{type Song}

pub type Model {
  Model(route: Route, songs: List(Song))
}
