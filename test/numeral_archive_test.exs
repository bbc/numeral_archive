defmodule NumeralArchiveTest do
  use ExUnit.Case

  test "builds array representation of a series" do
    series = [
      [{700, 5}, {400, 2}, {1_200, 3}, {200, 2}, {500, 1}],
      [{600, 2}, {400, 2}, {300, 3}, {2_100, 3}, {400, 2}]
    ]

    assert [140.0, 230.77, 316.67] == NumeralArchive.to_array(series)
  end

  def process_data_set(series, data_set) do
    data_set
    |> Enum.reduce(series, fn values, series ->
      # Add batches of values to find average of, before calling `tick`
      # to simulate each passing minute
      Enum.reduce(values, series, &NumeralArchive.increment(&2, &1))
      |> NumeralArchive.tick()
    end)
  end

  test "builds text summary of results" do
    series = [
      [{700, 5}, {400, 2}, {1_200, 3}, {200, 2}, {500, 1}],
      [{600, 2}, {400, 2}, {300, 3}, {2_100, 3}, {400, 2}]
    ]

    expected = ~s(0m -> 1m ago: 140.0 average.
0m -> 5m ago: 230.77 average.
5m -> 30m ago: 316.67 average.)
    assert expected == NumeralArchive.summary(series, {1, "m"})
  end

  describe "end to end tests" do
    setup do
      time_interval_one = [20, 50, 10, 70, 30]
      time_interval_two = [30, 100, 10, 5, 70, 90]

      %{
        fixture_one: [time_interval_one, time_interval_two],
        fixture_two: Enum.to_list(0..200) |> Enum.chunk_every(1),
        incr_data: Enum.to_list(0..500) |> Enum.chunk_every(3),
        decr_data: Enum.to_list(0..500) |> Enum.reverse() |> Enum.chunk_every(3)
      }
    end

    test "a small data set", %{fixture_one: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {2,
              [
                [{0, 0}, {305, 6}, {180, 5}, {0, 0}, {0, 0}],
                [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
              ]} == actual

      first_time_period_average = nil
      first_stage_average = 44.09
      second_stage_average = nil

      assert [
               first_time_period_average,
               first_stage_average,
               second_stage_average
             ] == NumeralArchive.to_array(elem(actual, 1))
    end

    test "many ticks", %{fixture_two: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {201,
              [
                [{0, 0}, {200, 1}, {199, 1}, {198, 1}, {197, 1}],
                [{990, 5}, {965, 5}, {940, 5}, {915, 5}, {890, 5}]
              ]} == actual

      first_time_period_average = nil
      first_stage_average = 198.5
      second_stage_average = 188.0

      assert [
               first_time_period_average,
               first_stage_average,
               second_stage_average
             ] == NumeralArchive.to_array(elem(actual, 1))
    end

    test "when average is increasing test", %{incr_data: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {167,
              [
                [{0, 0}, {1497, 3}, {1488, 3}, {1479, 3}, {1470, 3}],
                [{7350, 15}, {7125, 15}, {6900, 15}, {6675, 15}, {6450, 15}]
              ]} == actual

      assert [nil, 494.5, 460.0] == NumeralArchive.to_array(elem(actual, 1))
      expected_summary = ~s(0m -> 1m ago: No data.
0m -> 5m ago: 494.5 average.
5m -> 30m ago: 460.0 average.)
      assert expected_summary == NumeralArchive.summary(elem(actual, 1))
    end

    test "when average is decreasing test", %{decr_data: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {167,
              [
                [{0, 0}, {3, 3}, {12, 3}, {21, 3}, {30, 3}],
                [{150, 15}, {375, 15}, {600, 15}, {825, 15}, {1050, 15}]
              ]} == actual

      assert [nil, 5.5, 40.0] == NumeralArchive.to_array(elem(actual, 1))
      expected_summary = ~s(0m -> 1m ago: No data.
0m -> 5m ago: 5.5 average.
5m -> 30m ago: 40.0 average.)
      assert expected_summary == NumeralArchive.summary(elem(actual, 1))
    end
  end
end
