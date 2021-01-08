defmodule NumeralArchive.SeriesTest do
  use ExUnit.Case
  alias NumeralArchive.Series

  test "increments record to keep average of" do
    series = Series.init()

    assert {
             1,
             [
               [{5000, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
               [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
             ]
           } == Series.increment(series, 5_000)
  end

  test "adds new increment to existing" do
    series = Series.init()

    series = Series.increment(series, 2_000)

    assert {
             1,
             [
               [{7_000, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
               [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
             ]
           } == Series.increment(series, 5_000)
  end

  test "tick_count/1" do
    series =
      Series.init()
      |> Series.tick()
      |> Series.tick()
      |> Series.tick()

    assert 4 == Series.tick_count(series)
    assert 4 == NumeralArchive.tick_count(series), "tick_count/1 should be public in NumeralArchive"
  end

  test "calculates very first minute average, and inserts at stage one" do
    series =
      {1,
       [
         [{5_000, 10}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
         [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
       ]}

    assert {2,
            [
              [{0, 0}, {5_000, 10}, {0, 0}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage" do
    series =
      {6,
       [
         [{5_000, 10}, {400, 1}, {200, 2}, {250, 2}, {900, 3}],
         [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
       ]}

    assert {7,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {200, 2}, {250, 2}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage, when last stage contains data" do
    series =
      {10,
       [
         [{5_000, 10}, {400, 1}, {100, 1}, {1_000, 2}, {1_200, 4}],
         [200, 100, 700, {0, 0}, {0, 0}]
       ]}

    assert {11,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {100, 1}, {1000, 2}],
              [{7700, 18}, 200, 100, 700, {0, 0}]
            ]} == Series.tick(series)
  end

  test "pushes out last average" do
    sum = 5000
    count = 10

    series =
      {10,
       [
         [{sum, count}, {400, 1}, {300, 3}, {1_500, 3}, {300, 1}],
         [{800, 4}, {500, 5}, {1_400, 2}, {200, 1}, {1_600, 2}]
       ]}

    assert {11,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {300, 3}, {1500, 3}],
              [{7500, 18}, {800, 4}, {500, 5}, {1400, 2}, {200, 1}]
            ]} == Series.tick(series)
  end
end
