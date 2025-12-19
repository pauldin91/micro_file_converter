defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.Storage
  alias Core.Items
  alias Core.UploadFormatter

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
    upload_dir = Application.fetch_env!(:core, :uploads_dir)

    {:ok, batch} =
      Uploads.create_batch(%{status: "pending"})

    transform =
      get_in(params, ["batch", "transform"]) || :none

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join([upload_dir, batch.id, entry.client_name])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        {:ok, _picture} =
          Items.create_picture(%{
            batch_id: batch.id,
            transform: transform,
            name: entry.client_name,
            size: File.stat!(dest).size
          })

        {:ok, %{path: dest, client_name: entry.client_name, client_type: entry.client_type}}
      end)

    if uploaded_files != [] do
      metadata = Storage.save_files(batch.id, uploaded_files)

      metadata =
        metadata
        |> Map.put(:transform, params["batch"]["transform"])

      queue =
        cond do
          transform == :none -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(0)
          true -> Application.fetch_env!(:core, :processing_queues) |> Enum.at(1)
        end

      Core.Messages.RabbitPublisher.publish_message(queue, Jason.encode!(metadata))

      {:noreply,
       socket
       |> assign(:batch_id, batch.id)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploaded_files)
       |> put_flash(:info, "Files uploaded with batch id #{batch.id}")}
    else
      {:noreply, socket}
    end
  end
end
