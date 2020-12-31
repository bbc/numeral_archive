defmodule LossyAverage.SeriesTest do
  use ExUnit.Case
  alias LossyAverage.Series

  setup do
    %{
      init_series: LossyAverage.Series.init()
    }
  end

  test "calculates last minute average, and inserts in next level", %{init_series: init_series} do
    sum = 5000
    count = 10

    series = List.replace_at(init_series, 0, {sum, count})

    assert [
             {0, 0},
             [500.0, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil]
           ] == Series.tick(series)
  end
end
