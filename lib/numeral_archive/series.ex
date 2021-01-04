defmodule NumeralArchive.Series do
  alias NumeralArchive.Series.Stage

  @init_sum 0
  @init_count 0
  @stage_size 5

  def init do
    {0,
     [
       [{@init_sum, @init_count}, nil, nil, nil, nil],
       [nil, nil, nil, nil, nil]
     ]}
  end

  def tick({tick_counter, series}) do
    tick_stages = which_stages(tick_counter)

    series
    |> normalise()
    |> push_average_to_store(tick_stages)
    |> increment_tick_counter(tick_counter)
  end

  def increment({tick_counter, [[{sum, count} | first_stage_rest] | stages]}, value) do
    {
      tick_counter,
      [[{sum + value, count + 1} | first_stage_rest] | stages]
    }
  end

  def normalise(series) do
    Enum.map(series, &Stage.normalise_stage/1)
  end

  defp increment_tick_counter(series, tick_counter), do: {tick_counter + 1, series}

  defp which_stages(counter) when rem(counter, @stage_size) == 0 and counter >= @stage_size do
    [1, 0]
  end

  defp which_stages(_counter), do: [0]

  defp push_average_to_store(
         series,
         tick_stages
       ) do
    tick_stages
    |> Enum.reduce(series, &calc_new_average/2)
  end

  defp calc_new_average(stage_index, series) do
    new_average = Stage.calculate_stage_new_average(series, stage_index)

    Stage.push_new_average(series, stage_index, new_average)
  end
end
