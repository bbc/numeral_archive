defmodule NumeralArchive do
  @moduledoc """
  Documentation for NumeralArchive.
  """
  alias NumeralArchive.{Math, Series}

  defdelegate new_series(), to: NumeralArchive.Series, as: :init
  defdelegate tick(series), to: NumeralArchive.Series
  defdelegate increment(series, value), to: NumeralArchive.Series

  def to_array(series) do
    [mean(series, :first) | mean(series, :all)]
  end

  def summary(series, {interval_value, interval_unit} \\ {1, "m"}) do
    stage_count = Series.stage_count(series)

    [last_time_period, stage_one_average, stage_two_average] = to_array(series)

    Enum.join(
      [
        summary_line("0#{interval_unit}", "#{interval_value}#{interval_unit}", last_time_period),
        summary_line(
          "0#{interval_unit}",
          "#{stage_count * interval_value}#{interval_unit}",
          stage_one_average
        ),
        summary_line(
          "#{stage_count * interval_value}#{interval_unit}",
          "#{(stage_count + 1) * stage_count}#{interval_unit}",
          stage_two_average
        )
      ],
      "\n"
    )
  end

  def mean([first_stage | _rest], :first) do
    first_interval = Enum.at(first_stage, 0)
    {sum, count} = first_interval

    Math.mean(sum, count) |> r()
  end

  def mean(series, :all) do
    series
    |> Enum.map(fn stage ->
      {sum, count} = Series.TimeInterval.reduce_multiple(stage)

      Math.mean(sum, count) |> r()
    end)
  end

  defp r(nil), do: nil

  defp r(number), do: Float.round(number, 2)

  defp summary_line(from, till, average) do
    case average do
      nil -> ~s(#{from} -> #{till} ago: No data.)
      average -> ~s(#{from} -> #{till} ago: #{average} average.)
    end
  end
end
