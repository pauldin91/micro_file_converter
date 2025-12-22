defmodule Core.Mappings.Stored do
  @derive Jason.Encoder
  defstruct [:filename, :type, :path, :size]
end
