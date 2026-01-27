defmodule Core.Mappings.Batch do
  @derive Jason.Encoder
  defstruct [:id, :files, :timestamp, :transform,:status]
end
