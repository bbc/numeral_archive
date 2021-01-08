defmodule NumeralArchive.Strategy do
  @moduledoc """
  A behaviour that a strategy must implement, to be supported.
  """

  @type value :: Integer.t()

  @doc """
  Defines how data is promoted to the next stage in a series.
  """
  @callback reduce_to_snapshot(NumeralArchive.stage()) :: NumeralArchive.time_snapshot()

  @doc """
  Calculates the result for a stage.
  """
  @callback calculate(NumeralArchive.stage()) :: Integer.t() | Float.t()

  @doc """
  Defines postfix in summary to explain the results.
  """
  @callback result_postfix :: String.t()

  @doc """
  Defines how data is accumulated.
  """
  @callback increment(NumeralArchive.time_snapshot(), value) :: NumeralArchive.time_snapshot()
end
