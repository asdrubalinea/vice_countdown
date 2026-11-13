import countdown
import gleeunit

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn split_test() {
  assert countdown.split(90_061) == #(1, 1, 1, 1)
  assert countdown.split(59) == #(0, 0, 0, 59)
  assert countdown.split(0) == #(0, 0, 0, 0)
}
