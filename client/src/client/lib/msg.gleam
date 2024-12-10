import client/lib/path.{type Path}

pub type Msg {
    AddSong(title: String, path: Path)
    RenameSong(from: String, to: String)
}
