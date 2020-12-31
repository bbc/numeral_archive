defmodule LossyAverage.SeriesTest do
  use ExUnit.Case
  alias LossyAverage.Series

  setup do
    %{
      init_series: LossyAverage.Series.init()
    }
  end

  test "calculates very first minute average, and inserts at stage one", %{
    init_series: init_series
  } do
    sum = 5000
    count = 10

    series = List.replace_at(init_series, 0, {sum, count})

    tick_stages = [1]

    assert [
             {0, 0},
             [500.0, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil]
           ] == Series.tick(series, tick_stages)
  end

  test "moves last 5 minute average to next stage" do
    sum = 5000
    count = 10

    tick_stages = [2, 1]

    series = [
      {sum, count},
      [200, 400, 100, 500, 300],
      [nil, nil, nil, nil, nil]
    ]

    assert [
             {0, 0},
             [500, 200, 400, 100, 500],
             [300, nil, nil, nil, nil]
           ] == Series.tick(series, tick_stages)
  end

  test "moves last 5 minute average to next stage, when last stage contains data" do
    sum = 5000
    count = 10

    tick_stages = [2, 1]

    series = [
      {sum, count},
      [200, 400, 100, 500, 300],
      [200, 100, 700, nil, nil]
    ]

    assert [
             {0, 0},
             [500, 200, 400, 100, 500],
             [300, 200, 100, 700, nil]
           ] == Series.tick(series, tick_stages)
  end

  test "pushes out last average" do
    sum = 5000
    count = 10

    tick_stages = [2, 1]

    series = [
      {sum, count},
      [200, 400, 100, 500, 300],
      [200, 100, 700, 200, 800]
    ]

    assert [
             {0, 0},
             [500, 200, 400, 100, 500],
             [300, 200, 100, 700, 200]
           ] == Series.tick(series, tick_stages)
  end
end
