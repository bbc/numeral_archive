defmodule LossyAverage.Series do
  @doc """
  Called once per minute.
  """

  alias LossyAverage.Series.Stage

  @init_sum 0
  @init_count 0

  def init do
    [
      {0, 0},
      [nil, nil, nil, nil, nil],
      [nil, nil, nil, nil, nil]
    ]
  end

  def tick(series) do
    series
    |> push_average_to_store()
  end

  defp push_average_to_store(series = [{sum, count} | [first_period | periods]]) do
    last_min_average = sum / count

    first_period_with_new_average = [last_min_average | first_period]

    # Based on the time, which stages need to be adjusted?
    # -> each minute, stage 1
    # -> each 5 minutes, stage 2
    # -> each 10 minutes, stage 3

    # SHOULD ALWAYS BE IN DECREASING ORDER.
    stages_to_push_averages = [1]

    stages_to_push_averages
    |> Enum.reduce(series, &calc_new_average/2)
    |> reset_first_minute()
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
