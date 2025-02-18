import gleam/option.{type Option}

pub type Song {
  Song(
    id: Int,
    title: String,
    href: Option(String),
    filepath: Option(String),
    tags: List(String),
    created_at: Int,
  )
}

pub type Tag {
  Tag(id: Int, name: String)
}

pub type AuthUser {
  AuthUser(
    is_admin: Bool,
  )
}

pub fn is_admin_to_int(is_admin: Bool) {
  case is_admin {
    True -> 1
    False -> 0
  }
}
