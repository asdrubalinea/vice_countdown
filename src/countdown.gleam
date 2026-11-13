import gleam/float
import gleam/int
import gleam/list
import gleam/string
import gleam/time/calendar
import gleam/time/duration
import gleam/time/timestamp.{type Timestamp}
import lustre
import lustre/attribute.{class}
import lustre/effect
import lustre/element.{type Element, text}
import lustre/element/html.{div, img, p, span}
import lustre/element/keyed

// shortcut: hardcoded global unlock, midnight 19 Nov 2026 Central European Time (UTC+1)
// = 23:00 on the 18th in the Canary Islands; edit if Rockstar moves it again.
fn release() -> Timestamp {
  timestamp.from_calendar(
    calendar.Date(2026, calendar.November, 19),
    calendar.TimeOfDay(0, 0, 0, 0),
    duration.hours(1),
  )
}

fn pad(n: Int) -> String {
  int.to_string(n) |> string.pad_start(2, "0")
}

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

type Msg {
  Tick
}

fn init(_) -> #(Timestamp, effect.Effect(Msg)) {
  // 250ms so a late timer never visibly skips a second
  let tick = effect.from(fn(dispatch) { every(250, fn() { dispatch(Tick) }) })
  #(timestamp.system_time(), tick)
}

fn update(_now: Timestamp, msg: Msg) -> #(Timestamp, effect.Effect(Msg)) {
  case msg {
    Tick -> #(timestamp.system_time(), effect.none())
  }
}

@external(javascript, "./countdown_ffi.mjs", "every")
fn every(_ms: Int, _callback: fn() -> Nil) -> Nil {
  Nil
}

/// Seconds → #(days, hours, minutes, seconds).
pub fn split(seconds: Int) -> #(Int, Int, Int, Int) {
  #(seconds / 86_400, seconds % 86_400 / 3600, seconds % 3600 / 60, seconds % 60)
}

fn view(now: Timestamp) -> Element(Msg) {
  let left =
    timestamp.difference(now, release())
    |> duration.to_seconds
    |> float.truncate

  html.main([class("hud")], [
    img([class("logo"), attribute.src("/gtavi.svg"), attribute.alt("Grand Theft Auto VI")]),
    case left > 0 {
      True -> clock(left)
      False -> p([class("out")], [text("Out now")])
    },
  ])
}

fn clock(seconds: Int) -> Element(Msg) {
  let #(d, h, m, s) = split(seconds)
  div([class("clock"), attribute.role("timer")], [
    unit(d, "days"),
    unit(h, "hours"),
    unit(m, "min"),
    unit(s, "sec"),
  ])
}

fn unit(n: Int, label: String) -> Element(Msg) {
  div([class("unit")], [
    // keyed by position+digit: a changed digit is a new node, so its CSS tick animation replays
    keyed.div(
      [class("num")],
      list.index_map(string.to_graphemes(pad(n)), fn(digit, i) {
        #(int.to_string(i) <> digit, span([class("digit")], [text(digit)]))
      }),
    ),
    span([class("label")], [text(label)]),
  ])
}
