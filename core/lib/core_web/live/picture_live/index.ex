defmodule CoreWeb.PictureLive.Index do
  use CoreWeb, :live_view

  alias Core.Pictures
  alias Core.Pictures.Picture

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:pictures, Pictures.list_pictures())
     |> assign(:transaction_id, nil)
     |> assign(:metadata, nil)
     |> assign(:processing, false)
     |> allow_upload(:files,
       accept: :any,
       max_entries: 10,
       max_file_size: 50_000_000
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Picture")
    |> assign(:picture, Pictures.get_picture!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Picture")
    |> assign(:picture, %Picture{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pictures")
    |> assign(:picture, nil)
  end

  @impl true
  def handle_info({CoreWeb.PictureLive.FormComponent, {:saved, picture}}, socket) do
    {:noreply, stream_insert(socket, :pictures, picture)}
  end

  @impl true
  def handle_info({:processing_complete, transaction_id}, socket) do
    socket =
      socket
      |> assign(:processing, false)
      |> put_flash(:info, "Processing complete! Transaction ID: #{transaction_id}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    picture = Pictures.get_picture!(id)
    {:ok, _} = Pictures.delete_picture(picture)

    {:noreply, stream_delete(socket, :pictures, picture)}
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
    transaction_id = Ecto.UUID.generate()

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join(["priv/uploads", transaction_id, entry.client_name])
        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)
        %{path: dest, client_name: entry.client_name, client_type: entry.client_type}
      end)

    if uploaded_files != [] do
      metadata = Pictures.save_files(transaction_id, uploaded_files)

      # Start async processing
      pid = self()

      spawn(fn ->
        Process.sleep(5000)
        send(pid, {:processing_complete, transaction_id})
      end)

      {:noreply,
       socket
       |> assign(:transaction_id, transaction_id)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploaded_files)
       |> assign(:processing, true)}
    else
      {:noreply, socket}
    end
  end
end
