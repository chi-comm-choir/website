pub type Route {
  NotFound

  Index
  About
  Songs

  Login
  Signup(auth_code: String)
  CreateSong
  ShowSong(song_id: Int)
}
