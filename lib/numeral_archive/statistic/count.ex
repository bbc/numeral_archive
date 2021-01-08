defmodule NumeralArchive.Statistic.Count do
  @moduledoc """
  Calculates the mean statistic for a series
  """
  alias NumeralArchive.Series.TimeSnapshot
  alias NumeralArchive.Statistic.Mean

  @behaviour NumeralArchive.Statistic

  @impl NumeralArchive.Statistic
  def increment(_time_snapshot = {sum, _count}, value) do
    {sum + value, 1}
  end

  @impl NumeralArchive.Statistic
  def reduce_to_snapshot(stage) do
    snapshot_count = Enum.count(stage)

    Enum.reduce(stage, TimeSnapshot.new(), fn {sum, _count}, {total_sum, _acc_count} ->
      {total_sum + sum, snapshot_count}
    end)
  end

  @impl NumeralArchive.Statistic
  def calculate(stage), do: Mean.calculate(stage)

  @impl NumeralArchive.Statistic
  def result_postfix, do: "count"
end
