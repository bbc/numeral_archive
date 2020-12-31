defmodule LossyAverage.Math do
  def mean(sum, count) do
    sum / count
  end

  def mean(array) do
    Enum.sum(array) / Enum.count(array)
  end
end
