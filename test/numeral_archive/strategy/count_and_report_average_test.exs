defmodule NumeralArchive.Strategy.CountAndReportAverageTest do
  use ExUnit.Case
  alias NumeralArchive.Strategy.CountAndReportAverage
  import TestHelper, only: [process_data_set: 2]

  test "reduce_to_snapshot/1" do
    stage = [{2000, 2000}, {4000, 4000}, {200, 200}, {700, 700}, {150, 150}]

    assert {7050, 5} == CountAndReportAverage.reduce_to_snapshot(stage)
  end

  setup do
    %{
      fixture_data: List.duplicate(1, 500) |> Enum.chunk_every(3)
    }
  end

  test "full example using count strategy (increasing count)", %{fixture_data: fixture_data} do
    series = NumeralArchive.new_series(CountAndReportAverage)
    series = process_data_set(series, fixture_data)

    assert {167, NumeralArchive.Strategy.CountAndReportAverage,
            [
              [{0, 0}, {2, 1}, {3, 1}, {3, 1}, {3, 1}],
              [{15, 5}, {15, 5}, {15, 5}, {15, 5}, {15, 5}]
            ]} == series

    assert [nil, 2.75, 3.0] == NumeralArchive.to_array(series)

    assert ~s(0m -> 1m ago: No data.
0m -> 5m ago: 2.75 averaged count \(per 1m\).
5m -> 30m ago: 3.0 averaged count \(per 1m\).) == NumeralArchive.summary(series)
  end
end
