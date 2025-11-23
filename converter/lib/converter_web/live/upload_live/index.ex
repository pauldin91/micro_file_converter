defmodule ConverterWeb.UploadLive.Index do
  use ConverterWeb, :live_view

  alias Converter.Documents

  @impl true
  def mount(_, _, socket) do
    socket =
      socket
      |> allow_upload(:files,
        accept: ~w(.doc .docx .xls .xlsx .ppt .pptx .txt .md),
        max_entries: 10,
        max_file_size: 8_000_000
      )
      |> assign(:uploads, Documents.list_uploads())

    {:ok, socket}
  end

  @impl true

  def handle_params(params, _url, socket) do
    case socket.assigns.live_action do
      :new ->
        {:noreply,
         socket
         |> assign(:page_title, "New Upload")
         |> assign(:upload, %Converter.Documents.Upload{})}

      :edit ->
        upload = Converter.Documents.get_upload!(params["id"])

        {:noreply,
         socket
         |> assign(:page_title, "Edit Upload")
         |> assign(:upload, upload)}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  @spec handle_event(<<_::32>>, any(), Phoenix.LiveView.Socket.t()) :: {:noreply, map()}
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join(["uploads", socket.assigns.batch_id, entry.client_name])
        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        {:ok, dest}
      end)

    # Publish conversion event to Go processor
    # ConverterWeb.Rabbit.publish_conversion_request(socket.assigns.batch_id, uploaded_files)

    {:noreply, assign(socket, :status, :processing)}
  end
end
