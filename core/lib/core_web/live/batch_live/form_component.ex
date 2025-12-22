defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.UploadFormatter
  alias Core.Handlers
  alias Core.Storage
  alias Core.Mappings.Stored

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
        {:ok, ntry} =
          Storage.store_entry(%Core.Mappings.Entry{
            path: path,
            filename: entry.client_name,
            content_type: entry.client_type,
            batch_id: uuid
          })

        with {:ok, %File.Stat{size: size}} <- File.stat(ntry.path) do
          %Stored{ntry | size: size}
        else
          {:error, reason} -> {:error, reason}
        end
      end)

    dto = %Core.Mappings.Batch{
      files: uploaded_files,
      transform: transform,
      id: uuid,
      timestamp: DateTime.utc_now()
    }

    dbg(dto)

    {:ok, batch_id} =
      Handlers.create_batch_with_pictures(
        dto,
        %{user_id: user.id}
      )

    {:noreply,
     socket
     |> assign(:batch_id, batch_id)
     |> put_flash(:info, "Files uploaded with batch id #{batch_id}")}
  end
end
