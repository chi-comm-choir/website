import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/otp/actor
import gleam/option.{type Option, Some, None}
import gleam/dict.{type Dict}
import birl.{type Time}
import birl/duration

import gleam/io
import gleam/int
import gleam/bool

pub type CacheEntry {
  CacheEntry(user_id: Int, is_admin: Bool, timestamp: Time)
}

pub type CacheMessage {
  Get(token: String, reply_to: Subject(Option(CacheEntry)))
  Put(token: String, entry: CacheEntry)
  Remove(token: String)
  Clean
}

pub fn start_cache(
  cache: Dict(String, CacheEntry),
  parent_subject: Subject(Subject(CacheMessage))
) -> Result(Subject(CacheMessage), actor.StartError) {
  actor.start_spec(actor.Spec(
    init: fn() {
      let actor_subject = process.new_subject()
      process.send(parent_subject, actor_subject)
      let selector =
        process.new_selector()
        |> process.selecting(actor_subject, function.identity)

      actor.Ready(cache, selector)
    },
    init_timeout: 1000,
    loop: handle_message
  ))
}

pub fn cache_put(cache: Subject(CacheMessage), token: String, user_id: Int, is_admin: Bool) -> Nil {
  actor.send(cache, Put(token, CacheEntry(user_id, is_admin, birl.now())))
}

pub fn cache_get(cache: Subject(CacheMessage), token: String) -> Option(CacheEntry) {
  actor.call(cache, Get(token, _), 5000)
}

pub fn cache_remove(cache: Subject(CacheMessage), token: String) -> Nil {
  actor.send(cache, Remove(token))
}

fn cache_debug_print(cache: Dict(String, CacheEntry)) -> Nil {
  io.println("PRINTING FULL CACHE\n----------------")
  dict.each(cache, print_entry)
}

fn print_entry(token: String, entry: CacheEntry) -> Nil {
  let CacheEntry(id, admin, time) = entry
  io.println(
    "CACHE ENTRY-- TOKEN: " <> token
    <>"\nID: " <> int.to_string(id)
    <>"\nIS_ADMIN: " <> bool.to_string(admin)
    <>"\nTIMESTAMP: " <> birl.to_time_string(time)
  )
}

fn handle_message(
  msg: CacheMessage,
  cache: Dict(String, CacheEntry)
) -> actor.Next(CacheMessage, Dict(String, CacheEntry)) {
  io.println("Handling cache message")
  case dict.is_empty(cache) {
    True -> io.println("Cache is empty")
    False -> cache_debug_print(cache)
  }
  case msg {
    Put(token, entry) -> {
      io.println("--Inserting entry into cache--")
      print_entry(token, entry)
      actor.continue(dict.insert(cache, token, entry))
    }
    Get(token, reply_to) -> case dict.get(cache, token) {
      Ok(entry) -> {
        let CacheEntry(id, _, _) = entry
        io.println("Got user id from cache: " <> int.to_string(id))
        process.send(reply_to, Some(entry))
        actor.continue(cache)
      }
      Error(_) -> {
        io.println("No associated user id found in cache")
        process.send(reply_to, None)
        actor.continue(cache)
      }
    }
    Remove(token) -> {
      io.println("Removing id from cache associated with token: " <> token)
      actor.continue(dict.drop(cache, [token]))
    }
    Clean -> {
      io.println("Cleaning cache!")
      actor.continue(dict.filter(cache, fn(_token, entry) {
        case entry {
          CacheEntry(_, _, timestamp) -> case birl.difference(timestamp, birl.now()) |> duration.blur_to(duration.Minute) {
            diff if diff > 5 -> False
            _ -> True
          }
        }
      }))
    }
  }
}

pub fn start_cleaner(_input: Nil, parent_subject: Subject(Subject(CacheMessage))) {
  // actor.start_spec(actor.Spec(
  //   init: fn() {
  //     let actor_subject = process.new_subject()
  //     process.send(parent_subject, actor_subject)
  //
  //     let selector =
  //       process.new_selector()
  //       |> process.selecting(actor_subject, function.identity)
  //
  //     actor.Ready(Nil, selector)
  //   },
  //   init_timeout: 1000,
  //   loop: cleaner
  // ))

  // process.start(
  //   fn() {
  //     process.sleep(60_000)
  //     actor.send(cache, Clean)
  //   },
  //   True
  // )
}

fn cleaner(_input: Nil, cache: Subject(CacheMessage)) {
  process.sleep(60_000)
  actor.send(cache, Clean)
  actor.continue(cache)
}
