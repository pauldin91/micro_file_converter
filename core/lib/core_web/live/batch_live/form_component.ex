defmodule CoreWeb.BatchLive.FormComponent do
  alias Core.Validators
  use CoreWeb, :live_component

  alias Core.Uploads
  alias Core.Uploads.Formatter
  alias Core.Handlers
  alias Core.Storage
  alias Core.Transforms

  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:mode, fn -> "convert" end)
     |> assign_new(:transform, fn -> "none" end)
     |> assign_new(:props_entries, fn -> [] end)
     |> assign(:transformations, Transforms.transformations())
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
  def handle_event("validate", %{"batch" => batch_params}, socket) do
    transform = batch_params["transform"] || socket.assigns.transform

    props_entries =
      Transforms.build_props_for_transform(transform, socket.assigns.transformations)

    changeset =
      socket.assigns.batch
      |> Uploads.change_batch(batch_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:transform, transform)
     |> assign(:props_entries, props_entries)}
  end

  def handle_event("validate", _params, socket),
    do: {:noreply, socket}

  def handle_event("toggle_transform", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, :mode, mode)}
  end

  def handle_event("add_prop", _params, socket) do
    entry = %{
      id: Ecto.UUID.generate(),
      key: "",
      value: ""
    }

    {:noreply,
     update(socket, :props_entries, fn entries ->
       entries ++ [entry]
     end)}
  end

  def handle_event("remove_prop", %{"id" => id}, socket) do
    {:noreply,
     update(socket, :props_entries, fn entries ->
       Enum.reject(entries, &(&1.id == id))
     end)}
  end

  @impl true
  def handle_event("save", _params, %{assigns: %{user: user}} = socket) do
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

    props =
      socket.assigns.props_entries
      |> Map.new(fn %{key: k, value: v} -> {k, to_string(v)} end)

    case Validators.Transform.validate(props, socket.assigns.transform) do
      {:ok, _spec} ->
        result =
          Handlers.handle_upload(user, %{
            files: uploaded_files,
            transform: socket.assigns.transform,
            props: props,
            batch_id: uuid
          })

        case result do
          {:ok, batch_id} ->
            {:noreply,
             socket
             |> assign(:batch_id, batch_id)
             |> put_flash(:info, "Files uploaded with batch id #{batch_id}")}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}

          :error ->
            {:noreply, put_flash(socket, :error, "Incognito error")}
        end

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def render_prop_input(assigns) do
    ~H"""
    <%= if @entry.meta[:selection] do %>
      <select name={"props[#{@entry.key}]"} class="select select-bordered w-full">
        <option
          :for={opt <- @entry.meta.selection}
          value={opt}
          selected={opt == @entry.value}
        >
          {opt}
        </option>
      </select>
    <% else %>
      <input
        type={(@entry.meta.type == :number && "number") || "text"}
        name={"props[#{@entry.key}]"}
        value={@entry.value}
        min={@entry.meta[:min]}
        max={@entry.meta[:max]}
        step={@entry.meta[:step]}
        class="input input-bordered w-full"
      />
    <% end %>
    """
  end
end
