import client/lib/file.{type File}
import client/lib/route.{type Route}

pub type Model {
    Model(route: Route, songs: List(File))
}
