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
end
