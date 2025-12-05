defmodule CoreWeb.PictureLive.Index do
  use CoreWeb, :live_view

  @upload_dir "priv/uploads"
  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign(:transaction_id, nil)
      |> assign(:metadata, nil)
      |> assign(:processing, false)
      |> allow_upload(:files,
        accept: :any,
        max_entries: 10,
        max_file_size: 50_000_000
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :files, ref)}
  end

  def handle_event("save", _params, socket) do
    transaction_id = create_transaction()

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join(["priv/uploads", transaction_id, entry.client_name])
        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        %{path: dest, client_name: entry.client_name, client_type: entry.client_type}
      end)

    if uploaded_files != [] do
      metadata = save_files(transaction_id, uploaded_files)

      # Start async processing
      pid = self()

      spawn(fn ->
        Process.sleep(5000)
        send(pid, {:processing_complete, transaction_id})
      end)

      socket =
        socket
        |> assign(:transaction_id, transaction_id)
        |> assign(:metadata, metadata)
        |> assign(:uploaded_files, uploaded_files)
        |> assign(:processing, true)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:processing_complete, transaction_id}, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> put_flash(:info, "Processing complete! Transaction ID: #{transaction_id}")

    {:noreply, socket}
  end

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  defp format_bytes(_), do: "Unknown"

  defp error_to_string(:too_large), do: "File is too large (max 50MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(_), do: "Upload error"

  defp create_transaction do
    Ecto.UUID.generate()
  end

  defp save_files(transaction_id, uploaded_entries) do
    transaction_dir = Path.join([@upload_dir, transaction_id])

    metadata = %{
      transaction_id: transaction_id,
      timestamp: DateTime.utc_now(),
      files: [],
      file_count: length(uploaded_entries)
    }

    files_metadata =
      Enum.map(uploaded_entries, fn entry ->
        %{
          filename: entry.client_name,
          size: File.stat!(entry.path).size,
          content_type: entry.client_type
        }
      end)

    final_metadata = %{metadata | files: files_metadata}

    # Save metadata as JSON
    metadata_path = Path.join([transaction_dir, "metadata.json"])
    File.write!(metadata_path, Jason.encode!(final_metadata, pretty: true))

    final_metadata
  end
end
