defmodule NumeralArchive.Series.TimeSnapshot do
  @init_sum 0
  @init_count 0

  def new, do: new(sum: @init_sum, count: @init_count)
  def new(sum: sum, count: count), do: {sum, count}

  def reduce_multiple(time_intervals) do
    Enum.reduce(time_intervals, new(), fn {sum, count}, {total_sum, total_count} ->
      {total_sum + sum, total_count + count}
    end)
  end
end
