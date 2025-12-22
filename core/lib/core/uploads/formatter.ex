defmodule Core.Uploads.Formatter do
  def format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  def format_bytes(_), do: "Unknown"

  def error_to_string(:too_large), do: "File is too large (max 50MB)"
  def error_to_string(:too_many_files), do: "Too many files (max 10)"
  def error_to_string(:not_accepted), do: "File type not accepted"
  def error_to_string(_), do: "Upload error"
end
