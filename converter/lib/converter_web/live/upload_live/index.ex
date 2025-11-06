defmodule ConverterWeb.UploadLive do
  use ConverterWeb, :live_view
  import Phoenix.LiveView.Helpers

  alias FileConverter.Files

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Upload your documents</h1>

    <.simpleform let={f} for={:upload} phx-submit="save">
      {live_file_input(@uploads.documents)}
      {submit("Upload")}
    </.simpleform>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     allow_upload(socket, :documents,
       accept: ~w(.pdf .docx .txt .rtf),
       max_entries: 5,
       max_file_size: 10_000_000
     )}
  end

  @impl true
  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :documents, fn %{path: path}, entry ->
        dest = Path.join(["priv/static/uploads", entry.client_name])
        File.cp!(path, dest)
        {:ok, dest}
      end)

    {:noreply, put_flash(socket, :info, "Uploaded #{length(uploaded_files)} files.")}
  end
end
