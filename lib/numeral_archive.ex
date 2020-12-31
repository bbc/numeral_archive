defmodule NumeralArchive do
  @moduledoc """
  Documentation for NumeralArchive.
  """
  alias NumeralArchive.Math

  defdelegate new_series(), to: NumeralArchive.Series, as: :init
  defdelegate tick(series), to: NumeralArchive.Series
  defdelegate increment(series, value), to: NumeralArchive.Series

  def to_array(series) do
    Enum.map(series, fn
      {sum, count} -> Math.mean(sum, count)
      averages when is_list(averages) -> Math.mean(averages)
    end)
  end
end
