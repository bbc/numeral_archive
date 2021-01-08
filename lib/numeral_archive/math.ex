defmodule NumeralArchive.Math do
  def mean(sum, count)
      when is_nil(sum)
      when is_nil(count)
      when count == 0,
      do: nil

  def mean(sum, count), do: sum / count

  def mean(array) do
    nums = numbers_only(array)

    Enum.reduce(nums, 0, fn
      value, total ->
        total + value
    end)
    |> case do
      0 -> 0
      sum -> sum / Enum.count(nums)
    end
  end

  defp numbers_only(arr), do: Enum.filter(arr, &is_number/1)
end
