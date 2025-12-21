defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.UploadFormatter
  alias Core.Handlers

  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Uploads.change_batch(batch))
     end)
     |> allow_upload(:files,
       accept: :any,
       max_entries: 10,
       max_file_size: 50_000_000
     )}
  end

  @impl true
  def handle_event("validate", params, socket) do
    batch_params = params["batch"] || %{}
    changeset = Uploads.change_batch(socket.assigns.batch, batch_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", params, socket) do
    user = socket.assigns.user

    transform =
      get_in(params, ["batch", "transform"]) || :none

    uuid = Ecto.UUID.generate()

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        Handlers.copy_uploaded_entry(%{
          path: path,
          filename: entry.client_name,
          type: entry.client_type,
          batch_id: uuid
        })
      end)

    {:ok, batch_id} =
      Handlers.register_batch_with_pictures(%{
        files: uploaded_files,
        transform: transform,
        id: uuid,
        user_id: user.id
      })

    {:noreply,
     socket
     |> assign(:batch_id, batch_id)
     |> put_flash(:info, "Files uploaded with batch id #{batch_id}")}
  end
end
