defmodule NumeralArchive.Strategy.CountAndReportAverage do
  @moduledoc """
  Counts value and reports the average per time interval.
  """
  alias NumeralArchive.Series.TimeSnapshot
  alias NumeralArchive.Strategy.Mean

  @behaviour NumeralArchive.Strategy

  @impl NumeralArchive.Strategy
  def increment(_time_snapshot = {sum, _count}, value) do
    {sum + value, 1}
  end

  @impl NumeralArchive.Strategy
  def reduce_to_snapshot(stage) do
    snapshot_count = Enum.count(stage)

    Enum.reduce(stage, TimeSnapshot.new(), fn {sum, _count}, {total_sum, _acc_count} ->
      {total_sum + sum, snapshot_count}
    end)
  end

  @impl NumeralArchive.Strategy
  def calculate(stage), do: Mean.calculate(stage)

  @impl NumeralArchive.Strategy
  def result_postfix, do: "count"
end
