defmodule NumeralArchive do
  @moduledoc """
  Documentation for NumeralArchive.
  """
  alias NumeralArchive.Math

  defdelegate new_series(), to: NumeralArchive.Series, as: :init
  defdelegate tick(series), to: NumeralArchive.Series
  defdelegate increment(series, value), to: NumeralArchive.Series

  def to_array(series) do
    series
    |> Enum.with_index()
    |> Enum.flat_map(fn
      {averages, 0} -> [Enum.at(averages, 0), Math.mean(averages)]
      {averages, _index} -> [Math.mean(averages)]
    end)
  end
end
