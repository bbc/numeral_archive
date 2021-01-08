defmodule TestHelper do
  def process_data_set(series, data_set) do
    data_set
    |> Enum.reduce(series, fn values, series ->
      # Add batches of values to find average of, before calling `tick`
      # to simulate each passing minute
      Enum.reduce(values, series, &NumeralArchive.increment(&2, &1))
      |> NumeralArchive.tick()
    end)
  end
end
