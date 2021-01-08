defmodule NumeralArchive.Statistic.Mean do
  @moduledoc """
  Calculates the mean statistic for a series
  """
  alias NumeralArchive.Math
  alias NumeralArchive.Series.TimeSnapshot

  @behaviour NumeralArchive.Statistic

  @impl NumeralArchive.Statistic
  def reduce_to_snapshot(stage) do
    Enum.reduce(stage, TimeSnapshot.new(), fn {sum, count}, {total_sum, total_count} ->
      {total_sum + sum, total_count + count}
    end)
  end

  @impl NumeralArchive.Statistic
  def calculate(stage) do
    {sum, count} = reduce_to_snapshot(stage)

    Math.mean(sum, count) |> Math.round()
  end

  @impl NumeralArchive.Statistic
  def result_postfix, do: "average (mean)"
end
