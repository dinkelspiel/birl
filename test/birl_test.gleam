import gleam/order
import gleeunit
import gleeunit/should

import birl
import birl/duration

const iso_datetime = "1905-12-22T16:38:23.000+03:30"

const year = 1905

const month = 12

const date = 22

const hour = 16

const minute = 38

const second = 23

const milli_second = 0

const offset = "+03:30"

pub fn main() {
  gleeunit.main()
}

// `birl` tests

pub fn now_test() {
  birl.now()
  |> birl.to_iso8601
  |> birl.parse
  |> should.be_ok
}

pub fn add_test() {
  let a = birl.now()
  let b = birl.add(a, duration.new([#(9_192_631_770, duration.Second)]))
  birl.compare(a, b)
  |> should.equal(order.Lt)
}

pub fn subtract_test() {
  let a = birl.now()
  let b = birl.subtract(a, duration.new([#(1300, duration.MilliSecond)]))
  birl.compare(a, b)
  |> should.equal(order.Gt)
}

pub fn equality_test() {
  let dt = birl.now()
  birl.compare(dt, dt)
  |> should.equal(order.Eq)
}

pub fn to_parts_test() {
  let time =
    birl.parse(iso_datetime)
    |> should.be_ok

  time
  |> birl.get_day
  |> should.equal(birl.Day(year, month, date))

  time
  |> birl.get_time_of_day
  |> should.equal(birl.TimeOfDay(hour, minute, second, milli_second))

  time
  |> birl.get_offset
  |> should.equal(offset)
}

pub fn get_date_accessor_test() {
  let date_time =
    iso_datetime
    |> birl.parse
    |> should.be_ok

  let day = birl.get_day(date_time)

  day.year
  |> should.equal(year)

  day.month
  |> should.equal(month)

  day.date
  |> should.equal(date)

  let time = birl.get_time_of_day(date_time)

  time.hour
  |> should.equal(hour)

  time.minute
  |> should.equal(minute)

  time.second
  |> should.equal(second)

  time.milli_second
  |> should.equal(milli_second)
}

pub fn from_parts_test() {
  birl.unix_epoch
  |> birl.set_offset(offset)
  |> should.be_ok
  |> birl.set_day(birl.Day(year, month, date))
  |> birl.set_time_of_day(birl.TimeOfDay(hour, minute, second, milli_second))
  |> birl.to_iso8601
  |> should.equal(iso_datetime)
}

pub fn circular_test() {
  let dt = birl.now()
  dt
  |> birl.add(duration.new([#(4, duration.Year)]))
  |> birl.subtract(duration.new([#(4 * 365, duration.Day)]))
  |> birl.compare(dt)
  |> should.equal(order.Eq)
}

pub fn weird_value1_test() {
  "2019-03-26T14:00:00.9Z"
  |> birl.parse
  |> should.be_ok
  |> birl.to_iso8601
  |> should.equal("2019-03-26T14:00:00.900Z")
}

pub fn weird_value2_test() {
  "2019-03-26T14:00:00,4999Z"
  |> birl.parse
  |> should.be_ok
  |> birl.to_iso8601
  |> should.equal("2019-03-26T14:00:00.499Z")
}

pub fn weird_value3_test() {
  "20190326t1400-4"
  |> birl.parse
  |> should.be_ok
  |> birl.to_iso8601
  |> should.equal("2019-03-26T14:00:00.000-04:00")
}

pub fn weird_value4_test() {
  "2019t14-4"
  |> birl.parse
  |> should.be_ok
  |> birl.to_iso8601
  |> should.equal("2019-01-01T14:00:00.000-04:00")
}

pub fn weird_value5_test() {
  "2019-03-26+35"
  |> birl.parse
  |> should.be_ok
  |> birl.to_iso8601
  |> should.equal("2019-03-26T00:00:00.000+03:05")
}

pub fn weird_value6_test() {
  "2019t14"
  |> birl.from_naive
  |> should.be_ok
  |> birl.to_naive
  |> should.equal("2019-01-01T14:00:00.000")
}

pub fn weird_value7_test() {
  "2019-4"
  |> birl.from_naive
  |> should.be_ok
  |> birl.to_naive
  |> should.equal("2019-04-01T00:00:00.000")
}

pub fn weird_value8_test() {
  "20190326t1400,02"
  |> birl.from_naive
  |> should.be_ok
  |> birl.to_naive
  |> should.equal("2019-03-26T14:00:00.020")
}

pub fn time_of_day_to_string_test() {
  birl.time_of_day_to_string(birl.TimeOfDay(8, 5, 9, 2))
  |> should.equal("8:05:09.002")

  birl.time_of_day_to_string(birl.TimeOfDay(16, 30, 20, 999))
  |> should.equal("16:30:20.999")

  birl.time_of_day_to_string(birl.TimeOfDay(0, 0, 0, 0))
  |> should.equal("0:00:00.000")
}

pub fn time_of_day_to_short_string_test() {
  birl.time_of_day_to_short_string(birl.TimeOfDay(8, 5, 9, 2))
  |> should.equal("8:05")

  birl.time_of_day_to_short_string(birl.TimeOfDay(16, 30, 20, 999))
  |> should.equal("16:30")

  birl.time_of_day_to_short_string(birl.TimeOfDay(0, 0, 0, 0))
  |> should.equal("0:00")
}

pub fn parse_weekday_test() {
  birl.parse_weekday("mon")
  |> should.equal(Ok(birl.Mon))

  birl.parse_weekday("tuesday")
  |> should.equal(Ok(birl.Tue))

  birl.parse_weekday("Wednesday")
  |> should.equal(Ok(birl.Wed))

  birl.parse_weekday("THU")
  |> should.equal(Ok(birl.Thu))

  birl.parse_weekday("not a weekday")
  |> should.be_error
}

pub fn weekday_to_string_test() {
  birl.weekday_to_string(birl.Fri)
  |> should.equal("Friday")

  birl.weekday_to_string(birl.Sat)
  |> should.equal("Saturday")
}

pub fn weekday_to_short_string_test() {
  birl.weekday_to_short_string(birl.Sun)
  |> should.equal("Sun")

  birl.weekday_to_short_string(birl.Mon)
  |> should.equal("Mon")
}

// `duration` tests

pub fn blur_test() {
  // unchanged
  duration.seconds(59)
  |> duration.blur
  |> should.equal(#(59, duration.Second))

  // exact value
  duration.seconds(60)
  |> duration.blur
  |> should.equal(#(1, duration.Minute))

  // almost rounded
  duration.seconds(99)
  |> duration.blur
  |> should.equal(#(1, duration.Minute))

  // rounded
  duration.seconds(100)
  |> duration.blur
  |> should.equal(#(2, duration.Minute))

  // goes through many units
  duration.seconds(60 * 60 * 24 * 400)
  |> duration.blur
  |> should.equal(#(1, duration.Year))
}
