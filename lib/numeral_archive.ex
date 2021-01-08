defmodule NumeralArchive do
  @moduledoc """
  Documentation for NumeralArchive.
  """
  @type time_snapshot :: NumeralArchive.Series.TimeSnapshot.t()
  @type stage :: NumeralArchive.Series.Stage.t()

  @default_strategy NumeralArchive.Strategy.Mean

  defdelegate new_series(strategy \\ @default_strategy), to: NumeralArchive.Series, as: :init
  defdelegate tick(series), to: NumeralArchive.Series
  defdelegate tick_count(series), to: NumeralArchive.Series
  defdelegate increment(series, value), to: NumeralArchive.Series
  defdelegate to_array(series), to: NumeralArchive.Report
  defdelegate summary(series, tick_interval \\ {1, "m"}), to: NumeralArchive.Report
end
