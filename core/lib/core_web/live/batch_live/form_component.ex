defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component
  alias Core.Uploads
  alias Core.Uploads.Formatter
  alias Core.Handlers
  alias Core.Storage

  @transformations [
    {"None", :none},
    {"90°", :rot_90},
    {"180°", :rot_180},
    {"270°", :rot_270},
    {"Mirror", :mirror}
  ]
  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:mode, fn -> "convert" end)
     |> assign_new(:transform, fn ->
       "none"
     end)
     |> assign_new(:show_transform, fn -> false end)
     |> assign(:transformations, @transformations)
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
  def handle_event("toggle_transform", params, socket) do
    mode = get_in(params, ["mode"])
    {:noreply, socket |> assign(show_transform: mode == "transform") |> assign(transform: "none")}
  end

  @impl true
  def handle_event("save", params, %{assigns: %{user: user}} = socket) do
    transform =
      get_in(params, ["batch", "transform"]) || "none"

    uuid = Ecto.UUID.generate()

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        Storage.store_entry(%Core.Mappings.Entry{
          path: path,
          filename: entry.client_name,
          content_type: entry.client_type,
          batch_id: uuid
        })
      end)

    result =
      Handlers.handle_upload(user, %{
        files: uploaded_files,
        transform: transform,
        batch_id: uuid
      })

    case result do
      {:ok, batch_id} ->
        {:noreply,
         socket
         |> assign(:batch_id, batch_id)
         |> put_flash(:info, "Files uploaded with batch id #{batch_id}")}

      :error ->
        {:noreply, put_flash(socket, :error, "Incognito error")}

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
            <input
              type="radio"
              name="mode"
              value="convert"
              checked={@mode == "convert"}
              phx-change="toggle_transform"
              phx-target={@myself}
            /> Convert
            <input
              type="radio"
              name="mode"
              value="transform"
              checked={@mode == "transform"}
              phx-change="toggle_transform"
              phx-target={@myself}
            />Transform
          </div>
        </div>

        <div :if={@show_transform} class="mt-4">
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
