defmodule NumeralArchive.SeriesTest do
  use ExUnit.Case
  alias NumeralArchive.Series

  test "increments record to keep average of" do
    series = Series.init()

    assert {
             0,
             [
               [{5000, 1}, nil, nil, nil, nil],
               [nil, nil, nil, nil, nil]
             ]
           } == Series.increment(series, 5_000)
  end

  test "calculates very first minute average, and inserts at stage one" do
    sum = 5000
    count = 10

    series = {0, [[{sum, count}, nil, nil, nil, nil], [nil, nil, nil, nil, nil]]}

    assert {1,
            [
              [{0, 0}, 500, nil, nil, nil],
              [nil, nil, nil, nil, nil]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage" do
    sum = 5000
    count = 10

    series =
      {5,
       [
         [{sum, count}, 400, 100, 500, 300],
         [nil, nil, nil, nil, nil]
       ]}

    assert {6,
            [
              [{0, 0}, 500, 400, 100, 500],
              [360, nil, nil, nil, nil]
            ]} == Series.tick(series)
  end

  test "moves last 5 minute average to next stage, when last stage contains data" do
    sum = 5000
    count = 10

    series =
      {10,
       [
         [{sum, count}, 400, 100, 500, 300],
         [200, 100, 700, nil, nil]
       ]}

    assert {11,
            [
              [{0, 0}, 500, 400, 100, 500],
              [360, 200, 100, 700, nil]
            ]} == Series.tick(series)
  end

  test "pushes out last average" do
    sum = 5000
    count = 10

    series =
      {10,
       [
         [{sum, count}, 400, 100, 500, 300],
         [200, 100, 700, 200, 800]
       ]}

    assert {11,
            [
              [{0, 0}, 500, 400, 100, 500],
              [360, 200, 100, 700, 200]
            ]} == Series.tick(series)
  end
end
