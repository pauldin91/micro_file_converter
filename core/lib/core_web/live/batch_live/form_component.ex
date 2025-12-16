defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.Items

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
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        File Upload Form
        <:subtitle>Use this form to manage batches in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="batch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.drag_n_drop files={@uploads.files} />
        <div class="mt-4 space-y-2">
          <label class="font-medium">Convert to pdf ?</label>

          <div class="mt-4 space-x-4">
            <input type="radio" name="convert" phx-click={JS.hide(to: "#convert")} /> Yes
            <input type="radio" name="convert" phx-click={JS.show(to: "#convert")} /> No
          </div>
        </div>

        <div id="convert" class="mt-4 hidden">
          <.input
            field={@form[:transform]}
            type="select"
            label="Transform"
            options={@transformations}
          />
        </div>

        <.display_uploads files={@uploads.files} />

        <div :for={err <- upload_errors(@uploads.files)} class="text-error text-sm mb-2">
          {Uploads.error_to_string(err)}
        </div>

        <:actions>
          <.button
            type="submit"
            disabled={@uploads.files.entries == []}
            class="btn btn-primary w-full"
          >
            Upload Files
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
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

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join([upload_dir, batch.id, entry.client_name])

        transform =
          get_in(params, ["batch", "transform"]) || :rot_90

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
      metadata = Uploads.save_files(batch.id, uploaded_files)

      metadata =
        metadata
        |> Map.put(:transform, params["batch"]["transform"])

      Core.Messages.RabbitPublisher.publish_message(Jason.encode!(metadata))

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
