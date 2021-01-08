defmodule NumeralArchiveTest do
  use ExUnit.Case
  import TestHelper, only: [process_data_set: 2]

  test "builds array representation of a series" do
    series =
      {234, NumeralArchive.Statistic.Mean,
       [
         [{700, 5}, {400, 2}, {1_200, 3}, {200, 2}, {500, 1}],
         [{600, 2}, {400, 2}, {300, 3}, {2_100, 3}, {400, 2}]
       ]}

    assert [140.0, 230.77, 316.67] == NumeralArchive.to_array(series)
  end

  test "builds text summary of results" do
    series = {
      345,
      NumeralArchive.Statistic.Mean,
      [
        [{700, 5}, {400, 2}, {1_200, 3}, {200, 2}, {500, 1}],
        [{600, 2}, {400, 2}, {300, 3}, {2_100, 3}, {400, 2}]
      ]
    }

    expected = ~s(0m -> 1m ago: 140.0 average \(mean\).
0m -> 5m ago: 230.77 average \(mean\).
5m -> 30m ago: 316.67 average \(mean\).)

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

      assert {2, NumeralArchive.Statistic.Mean,
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
             ] == NumeralArchive.to_array(actual)
    end

    test "many ticks", %{fixture_two: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {201, NumeralArchive.Statistic.Mean,
              [
                [{0, 0}, {200, 1}, {199, 1}, {198, 1}, {197, 1}],
                [{985, 5}, {960, 5}, {935, 5}, {910, 5}, {885, 5}]
              ]} == actual

      first_time_period_average = nil
      first_stage_average = 198.5
      second_stage_average = 187.0

      assert [
               first_time_period_average,
               first_stage_average,
               second_stage_average
             ] == NumeralArchive.to_array(actual)
    end

    test "when average is increasing test", %{incr_data: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {167, NumeralArchive.Statistic.Mean,
              [
                [{0, 0}, {1497, 3}, {1488, 3}, {1479, 3}, {1470, 3}],
                [{7305, 15}, {7080, 15}, {6855, 15}, {6630, 15}, {6405, 15}]
              ]} == actual

      assert [nil, 494.5, 457.0] == NumeralArchive.to_array(actual)
      expected_summary = ~s(0m -> 1m ago: No data.
0m -> 5m ago: 494.5 average \(mean\).
5m -> 30m ago: 457.0 average \(mean\).)
      assert expected_summary == NumeralArchive.summary(actual)
    end

    test "when average is decreasing test", %{decr_data: data_points} do
      actual = process_data_set(NumeralArchive.new_series(), data_points)

      assert {167, NumeralArchive.Statistic.Mean,
              [
                [{0, 0}, {3, 3}, {12, 3}, {21, 3}, {30, 3}],
                [{195, 15}, {420, 15}, {645, 15}, {870, 15}, {1095, 15}]
              ]} == actual

      assert [nil, 5.5, 43.0] == NumeralArchive.to_array(actual)
      expected_summary = ~s(0m -> 1m ago: No data.
0m -> 5m ago: 5.5 average \(mean\).
5m -> 30m ago: 43.0 average \(mean\).)
      assert expected_summary == NumeralArchive.summary(actual)
    end
  end

  test "ticks - step by step" do
    series = NumeralArchive.new_series()
    series = NumeralArchive.increment(series, 100)

    assert {0, NumeralArchive.Statistic.Mean,
            [
              [{100, 1}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {1, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {100, 1}, {0, 0}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {2, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {100, 1}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    series = NumeralArchive.increment(series, 101)

    assert {2, NumeralArchive.Statistic.Mean,
            [
              [{101, 1}, {0, 0}, {100, 1}, {0, 0}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {3, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {101, 1}, {0, 0}, {100, 1}, {0, 0}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {4, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {101, 1}, {0, 0}, {100, 1}],
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {5, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {0, 0}, {101, 1}, {0, 0}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    series = NumeralArchive.increment(series, 102)

    assert {5, NumeralArchive.Statistic.Mean,
            [
              [{102, 1}, {0, 0}, {0, 0}, {101, 1}, {0, 0}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {6, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {102, 1}, {0, 0}, {0, 0}, {101, 1}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    expectation_msg =
      ~s({101, 1} should drop off first stage, as it's already been counted in the first step of stage 2.)

    assert {7, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {102, 1}, {0, 0}, {0, 0}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series,
           expectation_msg

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {8, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {0, 0}, {102, 1}, {0, 0}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {9, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {102, 1}],
              [{201, 2}, {0, 0}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    series = NumeralArchive.increment(series, 103)

    # 1 minute passes
    series = NumeralArchive.tick(series)

    assert {10, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {103, 1}, {0, 0}, {0, 0}, {0, 0}],
              [{205, 2}, {201, 2}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series,
           "{103, 1} + {102, 1} becomes first step in stage 2"

    # 3 minute pass
    series = NumeralArchive.tick(series)
    series = NumeralArchive.tick(series)
    series = NumeralArchive.tick(series)

    assert {13, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {103, 1}],
              [{205, 2}, {201, 2}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series

    # 1 minute passes
    series = NumeralArchive.tick(series)

    expectation_msg =
      ~s({103, 1} should drop off first stage, as it's already been counted in the first step of stage 2.)

    assert {14, NumeralArchive.Statistic.Mean,
            [
              [{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}],
              [{205, 2}, {201, 2}, {0, 0}, {0, 0}, {0, 0}]
            ]} == series,
           expectation_msg

    expected_summary = ~s(0m -> 1m ago: No data.
0m -> 5m ago: No data.
5m -> 30m ago: 101.5 average \(mean\).)

    assert expected_summary == NumeralArchive.summary(series)
  end
end
