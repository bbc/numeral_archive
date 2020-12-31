defmodule NumeralArchive.Series do
  @doc """
  Called once per minute.
  """
  alias NumeralArchive.Series.Stage

  @init_sum 0
  @init_count 0
  @stage_size 5

  def init do
    {0,
     [
       # 0->1m (building the minute's average)
       {0, 0},
       # 1m->2m, 2m->3m, 3m->4m, 4m->5m
       [nil, nil, nil, nil, nil],
       # 5m->10m, 10m->15m, 15m->20m, 20m->25m, 25m->30m
       [nil, nil, nil, nil, nil]
     ]}
  end

  def tick({tick_counter, series}) do
    tick_stages = which_stages(tick_counter)

    push_average_to_store(series, tick_stages)
    |> reset_first_minute()
    |> increment_tick_counter(tick_counter)
  end

  def increment({tick_counter, [{sum, count} | stages]}, value) do
    {
      tick_counter,
      [{sum + value, count + 1} | stages]
    }
  end

  defp increment_tick_counter(series, tick_counter), do: {tick_counter + 1, series}

  defp which_stages(counter) when rem(counter, @stage_size) == 0 and counter >= @stage_size do
    [2, 1]
  end

  defp which_stages(_counter), do: [1]

  defp push_average_to_store(
         series,
         tick_stages
       ) do
    tick_stages
    |> Enum.reduce(series, &calc_new_average/2)
  end

  defp reset_first_minute(series) do
    Stage.replace_stage(series, 0, {@init_sum, @init_count})
  end

  defp calc_new_average(stage_index, series) do
    new_average = Stage.calculate_stage_new_average(series, stage_index)

    Stage.push_new_average(series, stage_index, new_average)
  end
end
