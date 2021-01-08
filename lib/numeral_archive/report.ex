defmodule NumeralArchive.Report do
  def to_array({_tick_counter, statistic, stages}) do
    [[first_step_in_first_stage | _steps_in_stage] | _stages] = stages

    first_time_period_result = statistic.calculate([first_step_in_first_stage])

    all =
      Enum.map(stages, fn stage ->
        statistic.calculate(stage)
      end)

    [first_time_period_result | all]
  end

  def summary(series = {_tick_counter, statistic, stages}, {interval_value, interval_unit}) do
    stage_count = NumeralArchive.Series.stage_count(stages)

    [last_time_period, stage_one, stage_two] = to_array(series)

    Enum.join(
      [
        summary_line(
          "0#{interval_unit}",
          "#{interval_value}#{interval_unit}",
          last_time_period,
          statistic.result_postfix()
        ),
        summary_line(
          "0#{interval_unit}",
          "#{stage_count * interval_value}#{interval_unit}",
          stage_one,
          statistic.result_postfix()
        ),
        summary_line(
          "#{stage_count * interval_value}#{interval_unit}",
          "#{(stage_count + 1) * stage_count}#{interval_unit}",
          stage_two,
          statistic.result_postfix()
        )
      ],
      "\n"
    )
  end

  defp summary_line(from, till, result, result_postfix) do
    case result do
      nil -> ~s(#{from} -> #{till} ago: No data.)
      result -> ~s(#{from} -> #{till} ago: #{result} #{result_postfix}.)
    end
  end
end
