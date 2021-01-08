defmodule NumeralArchive.Series do
  alias NumeralArchive.Series.{Stage, TimeSnapshot}

  @stage_size 5
  @stage_count 2
  @all_stages [1, 0]
  @first_stage [0]

  def init(strategy) do
    stage = List.duplicate(TimeSnapshot.new(), @stage_size)
    {0, strategy, List.duplicate(stage, @stage_count)}
  end

  def tick({tick_counter, strategy, stages}) do
    {tick_counter, stages} = {tick_counter + 1, stages}

    stage_indexes_to_alter = which_stages(tick_counter)

    stages = tick_stages(stages, strategy, stage_indexes_to_alter)

    {tick_counter, strategy, stages}
  end

  def tick_count(series), do: elem(series, 0)

  def increment(
        {tick_counter, strategy, [[first_step_of_first_stage | first_stage_rest] | stages]},
        value
      ) do
    {
      tick_counter,
      strategy,
      [[strategy.increment(first_step_of_first_stage, value) | first_stage_rest] | stages]
    }
  end

  def stage_count(_series = [stage_one, _rest]) do
    Enum.count(stage_one)
  end

  defp which_stages(counter) when rem(counter, @stage_size) == 0 and counter > 1 do
    @all_stages
  end

  defp which_stages(_counter), do: @first_stage

  defp tick_stages(
         stages,
         strategy,
         tick_stages
       ) do
    tick_stages
    |> Enum.reduce(stages, &promote_time_interval(&1, &2, strategy))
  end

  defp promote_time_interval(stage_index = 0, stages, _strategy) do
    Stage.tick_stage(stages, stage_index, TimeSnapshot.new())
  end

  defp promote_time_interval(stage_index, stages, strategy) do
    previous_stage = Stage.previous_stage(stages, stage_index)
    snapshot = strategy.reduce_to_snapshot(previous_stage)

    Stage.tick_stage(stages, stage_index, snapshot)
  end
end
