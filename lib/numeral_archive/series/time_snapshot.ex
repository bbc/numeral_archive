defmodule NumeralArchive.Series.TimeSnapshot do
  @init_sum 0
  @init_count 0

  @type t :: {integer(), integer()}

  def new, do: new(sum: @init_sum, count: @init_count)
  def new(sum: sum, count: count), do: {sum, count}
end
