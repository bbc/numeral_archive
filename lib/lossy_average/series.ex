defmodule LossyAverage.Series do
  @doc """
  Called once per minute.
  """
  alias LossyAverage.Series.Stage

  @init_sum 0
  @init_count 0
  @stage_size 5

  def init do
    {0,
     [
       {0, 0},
       [nil, nil, nil, nil, nil],
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

# internal data structure:
# %{
#   "an-origin" => [
#     {sum, count},
#     [<avg min ago>, <avg 2 mins ago>, <avg 3 mins ago>, <avg 4 mins ago>, <avg 5 mins ago>],
#     [<5 mins ago average>, <10 mins ago average>, <15 mins ago average>, <20 mins ago average>, <25 mins ago average>, <30 mins ago average>]
#   ]
# }

# displayed data structure:

# %{
#   "an-origin" => [<avg last minute>, <avg 5 over last 5 mins>, <avg over last 30 mins>]
# }

# Every 1 minute, position 1 moves into first position in list 2.
