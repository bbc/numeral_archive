defmodule NumeralArchive.Series.Stage do
  @moduledoc """
  Helpers for manipulating the each stage.
  """
  alias NumeralArchive.Math

  @doc """
  When first stage, average is the `sum / count`
  so slightly different from calulating other averages.
  """
  def calculate_stage_new_average([{sum, count} | _rest], 1) do
    Math.mean(sum, count)
  end

  def calculate_stage_new_average(series, stage_index) do
    previous_stage(series, stage_index)
    |> Math.mean()
  end

  def push_new_average(series, stage_index, average) do
    replace_stage(series, stage_index, fn stage ->
      stage_size = Enum.count(stage)
      Enum.take([average | stage], stage_size)
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
