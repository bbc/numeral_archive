defmodule NumeralArchive.Math do
  def mean(sum, count)
      when is_nil(sum)
      when is_nil(count)
      when count == 0,
      do: nil

  def mean(sum, count), do: sum / count

  def mean(array) do
    sum =
      Enum.reduce(array, 0, fn
        {sum, count}, total ->
          mean(sum / count) + total

        value, total ->
          total + value
      end)

    sum / Enum.count(array)

    # IO.inspect(array, label: "array")
    # Enum.sum(array) / Enum.count(array)
  end
end
