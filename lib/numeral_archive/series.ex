defmodule NumeralArchive.Series do
  alias NumeralArchive.Series.{Stage, TimeInterval}

  @stage_size 5
  @stage_count 2
  @all_stages [1, 0]
  @first_stage [0]

  def init do
    stage = List.duplicate(TimeInterval.new(), @stage_size)
    {1, List.duplicate(stage, @stage_count)}
  end

  def tick({tick_counter, series}) do
    tick_stages = which_stages(tick_counter)

    series
    |> tick_stages(tick_stages)
    |> increment_tick_counter(tick_counter)
  end

  def increment({tick_counter, [[{sum, count} | first_stage_rest] | stages]}, value) do
    {
      tick_counter,
      [[{sum + value, count + 1} | first_stage_rest] | stages]
    }
  end

  def stage_count(_series = [stage_one, _rest]) do
    Enum.count(stage_one)
  end

  defp increment_tick_counter(series, tick_counter), do: {tick_counter + 1, series}

  defp which_stages(counter) when rem(counter, @stage_size) == 0 and counter > 1 do
    @all_stages
  end

  defp which_stages(_counter), do: @first_stage

  defp tick_stages(
         series,
         tick_stages
       ) do
    tick_stages
    |> Enum.reduce(series, &promote_time_interval/2)
  end

  defp promote_time_interval(stage_index = 0, series) do
    Stage.tick_stage(series, stage_index, TimeInterval.new())
  end

  defp promote_time_interval(stage_index, series) do
    previous_stage = Stage.previous_stage(series, stage_index)
    time_interval = Stage.time_interval(previous_stage)

    Stage.tick_stage(series, stage_index, time_interval)
  end
end
