defmodule NumeralArchive.Statistic do
  @moduledoc """
  A behaviour that a statistic must implement, to be supported.
  """

  @callback reduce_to_snapshot(NumeralArchive.stage()) :: NumeralArchive.time_snapshot()
  @callback calculate(NumeralArchive.stage()) :: Integer.t() | Float.t()
  @callback result_postfix :: String.t()
end
