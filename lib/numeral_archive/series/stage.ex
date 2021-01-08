defmodule NumeralArchive.Series.Stage do
  @moduledoc """
  Helpers for manipulating a stage.
  """
  alias NumeralArchive.Series.TimeSnapshot

  @type t :: [TimeSnapshot.t()]

  def tick_stage(stages, stage_index, new_time_interval_data) do
    replace_stage(stages, stage_index, fn stage ->
      stage_size = Enum.count(stage)
      Enum.take([new_time_interval_data | stage], stage_size)
    end)
  end

  def replace_stage(stages, stage_index, cb) when is_function(cb) do
    current_stage = Enum.at(stages, stage_index)
    replace_stage(stages, stage_index, cb.(current_stage))
  end

  def replace_stage(stages, stage_index, value) do
    List.replace_at(stages, stage_index, value)
  end

  def previous_stage(stages, stage_index) do
    Enum.at(stages, stage_index - 1)
  end
end
