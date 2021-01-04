defmodule NumeralArchive.Series.Stage do
  @moduledoc """
  Helpers for manipulating a stage.
  """
  alias NumeralArchive.Series.TimeInterval

  def time_interval(stage) do
    TimeInterval.reduce_multiple(stage)
  end

  def tick_stage(series, stage_index, new_time_interval_data) do
    replace_stage(series, stage_index, fn stage ->
      stage_size = Enum.count(stage)
      Enum.take([new_time_interval_data | stage], stage_size)
    end)
  end

  def replace_stage(series, stage_index, cb) when is_function(cb) do
    current_stage = Enum.at(series, stage_index)
    replace_stage(series, stage_index, cb.(current_stage))
  end

  def replace_stage(series, stage_index, value) do
    List.replace_at(series, stage_index, value)
  end

  def previous_stage(series, stage_index) do
    Enum.at(series, stage_index - 1)
  end
end
