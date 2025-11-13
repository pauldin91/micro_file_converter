defmodule ConverterWeb.UploadLive.Index do
  use ConverterWeb, :live_view

  alias Converter.Documents
  alias Converter.Documents.Upload

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     allow_upload(socket, :documents,
       accept: ~w(.doc .docx .xls .xlsx .ppt .pptx .txt .md),
       max_entries: 10
     )
     |> assign(:batch_id, Ecto.UUID.generate())
     |> assign(:status, :idle)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
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
