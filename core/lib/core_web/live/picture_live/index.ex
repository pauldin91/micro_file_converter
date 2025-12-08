defmodule CoreWeb.PictureLive.Index do
  use CoreWeb, :live_view

  alias Core.Items
  alias Core.Uploads
  alias Core.Items.Picture

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:uploaded_files, [])
      |> assign(:picture_id, nil)
      |> assign(:metadata, nil)
      |> assign(:form, to_form(Items.change_picture(%Picture{})))
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

  @impl true
  def handle_event("save", _params, socket) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)

    {:ok, batch} = Uploads.create_batch(%{status: "pending"})

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest =
          Path.join([
            upload_dir,
            batch.id,
            entry.client_name
          ])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        {:ok, _picture} =
          Items.create_picture(%{
            :batch_id => batch.id,
            :transform => "rotation_90",
            :name => entry.client_name,
            :size => File.stat!(dest).size
          })

        {:ok, %{path: dest, client_name: entry.client_name, client_type: entry.client_type}}
      end)

    dbg(uploaded_files)

    if uploaded_files != [] do
      metadata = Uploads.save_files(batch.id, uploaded_files)

      # Start async processing
      pid = self()

      spawn(fn ->
        Process.sleep(5000)
        send(pid, {:processing_complete, batch.id})
      end)

      {:noreply,
       socket
       |> assign(:picture_id, batch.id)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploaded_files)
       |> assign(:processing, true)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:processing_complete, picture_id}, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> put_flash(:info, "Processing complete! Transaction ID: #{picture_id}")

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
end
