defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Uploads.Batch
  alias Core.Items
  alias Core.Items.Picture

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(:batches, Uploads.list_batches())
     |> assign(:uploaded_files, [])
     |> assign(:picture_id, nil)
     |> assign(:metadata, nil)
     |> assign(:form, to_form(Items.change_picture(%Picture{})))
     |> assign(:processing, false)
     |> assign(:show_modal, false)
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
    |> assign(:page_title, "Edit Batch")
    |> assign(:batch, Uploads.get_batch!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Batch")
    |> assign(:batch, %Batch{})
    |> assign(:show_modal, true)
    |> assign(:form, to_form(Items.change_picture(%Picture{})))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Batches")
    |> assign(:batch, nil)
    |> assign(:show_modal, false)
  end

  @impl true
  def handle_info({CoreWeb.BatchLive.FormComponent, {:saved, batch}}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    batch = Uploads.get_batch!(id)
    {:ok, _} = Uploads.delete_batch(batch)

    {:noreply, stream_delete(socket, :batches, batch)}
  end

  # user clicked cancel on the modal/form
  def handle_event("cancel", _params, socket) do
    {:noreply, push_patch(socket, to: Routes.batch_index_path(socket, :index))}
  end

  # user clicked save/submit on the modal form — consume uploaded entries,
  # set processing state, show a message and redirect back to index after a delay
  def handle_event("save_picture", %{"picture" => picture_params}, socket) do
    entries = uploaded_entries(socket, :files)

    # consume entries and copy them to tmp dir (replace with your actual creation logic)
    consumed =
      for {_meta, entry} <- entries do
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          dest = Path.join(System.tmp_dir!(), entry.client_name || Path.basename(path))
          File.cp(path, dest)
          {:ok, dest}
        end)
      end

    # mark processing and schedule redirect after showing processed message
    Process.send_after(self(), :processing_done, 2_500)

    {:noreply,
     socket
     |> assign(:processing, true)
     |> assign(:uploaded_files, consumed)}
  end

  @impl true
  def handle_info(:processing_done, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Files processed")
     |> push_patch(to: Routes.batch_index_path(socket, :index))}
  end
end
