defmodule NumeralArchive.SeriesTest do
  use ExUnit.Case
  alias NumeralArchive.Series

  test "increments record to keep average of" do
    series = NumeralArchive.new_series()

    assert {
             0,
             NumeralArchive.Strategy.Mean,
             [
               [{5000, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
               [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
             ]
           } == Series.increment(series, 5_000)
  end

  test "adds new increment to existing" do
    series = NumeralArchive.new_series()

    series = Series.increment(series, 2_000)

    assert {
             0,
             NumeralArchive.Strategy.Mean,
             [
               [{7_000, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
               [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
             ]
           } == Series.increment(series, 5_000)
  end

  test "tick_count/1" do
    series =
      NumeralArchive.new_series()
      |> Series.tick()
      |> Series.tick()
      |> Series.tick()

    assert 3 == Series.tick_count(series)

    assert 3 == NumeralArchive.tick_count(series),
           "tick_count/1 should be public in NumeralArchive"
  end

  test "calculates very first minute average, and inserts at stage one" do
    series =
      {1, NumeralArchive.Strategy.Mean,
       [
         [{5_000, 10}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
         [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
       ]}

    assert {2, NumeralArchive.Strategy.Mean,
            [
              [{0, 0}, {5_000, 10}, {0, 0}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage" do
    series =
      {6, NumeralArchive.Strategy.Mean,
       [
         [{5_000, 10}, {400, 1}, {200, 2}, {250, 2}, {900, 3}],
         [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
       ]}

    assert {7, NumeralArchive.Strategy.Mean,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {200, 2}, {250, 2}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage, when last stage contains data" do
    series =
      {9, NumeralArchive.Strategy.Mean,
       [
         [{5_000, 10}, {400, 1}, {100, 1}, {1_000, 2}, {1_200, 4}],
         [{3000, 30}, {2500, 10}, {6500, 20}, {0, 0}, {0, 0}]
       ]}

    assert {10, NumeralArchive.Strategy.Mean,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {100, 1}, {1000, 2}],
              [{7700, 18}, {3000, 30}, {2500, 10}, {6500, 20}, {0, 0}]
            ]} == Series.tick(series)
  end

  test "pushes out last average" do
    sum = 5000
    count = 10

    series =
      {9, NumeralArchive.Strategy.Mean,
       [
         [{sum, count}, {400, 1}, {300, 3}, {1_500, 3}, {300, 1}],
         [{800, 4}, {500, 5}, {1_400, 2}, {200, 1}, {1_600, 2}]
       ]}

    assert {10, NumeralArchive.Strategy.Mean,
            [
              [{0, 0}, {5000, 10}, {400, 1}, {300, 3}, {1500, 3}],
              [{7500, 18}, {800, 4}, {500, 5}, {1400, 2}, {200, 1}]
            ]} == Series.tick(series)
  end
end
