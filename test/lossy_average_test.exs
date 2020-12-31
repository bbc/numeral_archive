defmodule LossyAverageTest do
  use ExUnit.Case

  test "builds array representation of a series" do
    series = [
      {700, 5},
      [500.00, 200, 400, 100, 500],
      [300.00, 200, 100, 700, 200]
    ]

    assert [140, 340, 300] == LossyAverage.to_array(series)
  end

  def process_data_set(series, data_set) do
    data_set
    |> Enum.reduce(series, fn values, series ->
      # Add batches of 10 values to find average of, before calling `tick`
      # to simulate each passing minute
      Enum.reduce(values, series, &LossyAverage.increment(&2, &1))
      |> LossyAverage.tick()
    end)
  end

  describe "end to end tests" do
    setup do
      %{
        incr_data: Enum.to_list(0..500) |> Enum.chunk_every(10),
        decr_data: Enum.to_list(0..500) |> Enum.reverse() |> Enum.chunk_every(10)
      }
    end

    test "when average is increasing test", %{incr_data: data_points} do
      actual = process_data_set(LossyAverage.new_series(), data_points)

      assert {51,
              [
                {0, 0},
                [500.0, 494.5, 484.5, 474.5, 464.5],
                [474.5, 424.5, 374.5, 324.5, 274.5]
              ]} == actual

      assert [nil, 483.6, 374.5] == LossyAverage.to_array(elem(actual, 1))
    end

    test "when average is decreasing test", %{decr_data: data_points} do
      actual = process_data_set(LossyAverage.new_series(), data_points)

      assert {51,
              [
                {0, 0},
                [0, 5.5, 15.5, 25.5, 35.5],
                [25.5, 75.5, 125.5, 175.5, 225.5]
              ]} == actual

      assert [nil, 16.4, 125.5] == LossyAverage.to_array(elem(actual, 1))
    end
  end
end
