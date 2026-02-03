defmodule Core.Mappings.Batch do
  @derive Jason.Encoder
  defstruct [:id, :files, :timestamp,:status, :transform]
end
