defmodule Core.Mappings.Stored do
  @derive Jason.Encoder
  defstruct [:filename, :content_type, :size]
end
