defmodule NumeralArchive.Series.Stage do
  @moduledoc """
  Helpers for manipulating the each stage.
  """
  alias NumeralArchive.Math

  def calculate_stage_new_average(_series, 0) do
    {0, 0}
  end

  def calculate_stage_new_average(series, stage_index) do
    previous_stage(series, stage_index) |> Math.mean()
  end

  def push_new_average(series, stage_index, average) do
    replace_stage(series, stage_index, fn stage ->
      stage_size = Enum.count(stage)
      Enum.take([average | stage], stage_size)
    end)
  end

  def normalise_stage(stage) do
    Enum.map(stage, fn
      {sum, count} -> Math.mean(sum, count)
      value -> value
    end)
  end

  def replace_stage(series, stage_index, cb) when is_function(cb) do
    current_stage = Enum.at(series, stage_index)
    replace_stage(series, stage_index, cb.(current_stage))
  end

  def replace_stage(series, stage_index, value) do
    List.replace_at(series, stage_index, value)
  end

  defp previous_stage(series, stage_index) do
    Enum.at(series, stage_index - 1)
  end
end
