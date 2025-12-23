defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.Uploads.Formatter
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

    case Handlers.handle_upload(socket.assigns.user, %{
           files: uploaded_files,
           transform: transform,
           batch_id: uuid
         }) do
      {:ok, batch_id} ->
        {:noreply,
         socket
         |> assign(:batch_id, batch_id)
         |> put_flash(:info, "Files uploaded with batch id #{batch_id}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        File Upload Form
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
          <div class="mt-4 space-x-4">
            <input type="radio" name="convert" phx-click={JS.hide(to: "#convert")} /> Convert
            <input type="radio" name="convert" phx-click={JS.show(to: "#convert")} /> Transform
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
          {Formatter.error_to_string(err)}
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
end
