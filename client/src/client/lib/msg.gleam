import client/lib/path.{type Path}
import lustre_http
import shared.{type Song, Song}

pub type Msg {
  AddSong(title: String, path: Path)
  RenameSong(from: String, to: String)
  SongsReceived(Result(GetSongsResponse, lustre_http.HttpError))
}

pub type GetSongsResponse {
  GetSongsResponse(songs: List(Song))
}
