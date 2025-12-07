defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component

  alias Core.Uploads
  alias Core.Items

  @impl true
  def mount(socket) do
    # LiveComponents mount with a blank socket — no assigns yet.
    {:ok, socket}
  end

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
        <:subtitle>Use this form to manage batch records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="batch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="mt-4">
          <.live_file_input upload={@uploads.files} class="sr-only" />
          <label for={@uploads.files.ref} class="cursor-pointer">
            <span class="mt-2 block text-sm font-medium text-base-content">
              Drop files here or click to browse
            </span>
          </label>
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Batch</.button>
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
  def handle_event("save", _params, socket) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)
    guid = Ecto.UUID.generate()

    {:ok, batch} = Uploads.create_batch(%{id: guid, status: "pending"})

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join([upload_dir, guid, entry.client_name])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        {:ok, _picture} =
          Items.create_picture(%{
            batch_id: guid,
            transform: "rotation_90",
            name: entry.client_name,
            size: File.stat!(dest).size
          })

        {:ok, %{path: dest, client_name: entry.client_name, client_type: entry.client_type}}
      end)

    if uploaded_files != [] do
      metadata = Uploads.save_files(guid, uploaded_files)

      pid = self()

      spawn(fn ->
        Process.sleep(5000)
        send(pid, {:processing_complete, guid})
      end)

      {:noreply,
       socket
       |> assign(:picture_id, guid)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploaded_files)
       |> assign(:processing, true)}
    else
      {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
