defmodule NumeralArchive.Report do
  def to_array({_tick_counter, strategy, stages}) do
    [[first_step_in_first_stage | _steps_in_stage] | _stages] = stages

    first_time_period_result = strategy.calculate([first_step_in_first_stage])

    all =
      Enum.map(stages, fn stage ->
        strategy.calculate(stage)
      end)

    [first_time_period_result | all]
  end

  def summary(series = {_tick_counter, strategy, stages}, {interval_value, interval_unit}) do
    stage_count = NumeralArchive.Series.stage_count(stages)

    [last_time_period, stage_one, stage_two] = to_array(series)

    Enum.join(
      [
        summary_line(
          "0#{interval_unit}",
          "#{interval_value}#{interval_unit}",
          last_time_period,
          strategy.result_postfix()
        ),
        summary_line(
          "0#{interval_unit}",
          "#{stage_count * interval_value}#{interval_unit}",
          stage_one,
          strategy.result_postfix()
        ),
        summary_line(
          "#{stage_count * interval_value}#{interval_unit}",
          "#{(stage_count + 1) * stage_count}#{interval_unit}",
          stage_two,
          strategy.result_postfix()
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
