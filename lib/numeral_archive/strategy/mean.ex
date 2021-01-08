defmodule NumeralArchive.Strategy.Mean do
  @moduledoc """
  Calculates the mean strategy for a series
  """
  alias NumeralArchive.Math
  alias NumeralArchive.Series.TimeSnapshot

  @behaviour NumeralArchive.Strategy

  @impl NumeralArchive.Strategy
  def increment(_time_snapshot = {sum, count}, value) do
    {sum + value, count + 1}
  end

  @impl NumeralArchive.Strategy
  def reduce_to_snapshot(stage) do
    Enum.reduce(stage, TimeSnapshot.new(), fn {sum, count}, {total_sum, total_count} ->
      {total_sum + sum, total_count + count}
    end)
  end

  @impl NumeralArchive.Strategy
  def calculate(stage) do
    {sum, count} = reduce_to_snapshot(stage)

    Math.mean(sum, count) |> Math.round()
  end

  @impl NumeralArchive.Strategy
  def result_postfix, do: "average (mean)"
end
