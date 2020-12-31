defmodule NumeralArchive.Math do
  def mean(sum, count)
      when is_nil(sum)
      when is_nil(count)
      when count == 0,
      do: nil

  def mean(sum, count), do: sum / count

  def mean(array), do: Enum.sum(array) / Enum.count(array)
end
