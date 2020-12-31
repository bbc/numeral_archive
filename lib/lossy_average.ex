defmodule LossyAverage do
  @moduledoc """
  Documentation for LossyAverage.
  """
  alias LossyAverage.Math

  defdelegate new_series(), to: LossyAverage.Series, as: :init

  def to_array(series) do
    Enum.map(series, fn
      {sum, count} -> Math.mean(sum, count)
      averages when is_list(averages) -> Math.mean(averages)
    end)
  end
end
