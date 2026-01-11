defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component

  alias Core.Uploads
  alias Core.Uploads.Formatter
  alias Core.Handlers
  alias Core.Storage

  @transformations [
    {"None", :none},
    {"Rotate", :rotate},
    {"Mirror", :mirror},
    {"Blur", :blur},
    {"Invert", :invert},
    {"Crop", :crop},
    {"Fractal", :fractal},
    {"Brighten", :brighten}
  ]

  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:mode, fn -> "convert" end)
     |> assign_new(:transform, fn -> "none" end)
     |> assign_new(:props_entries, fn -> [] end)
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
  def handle_event("validate", %{"batch" => batch_params} = params, socket) do
    changeset =
      socket.assigns.batch
      |> Uploads.change_batch(batch_params)
      |> Map.put(:action, :validate)

    props_entries =
      params
      |> Map.get("props", %{})
      |> Enum.map(fn {id, %{"key" => k, "value" => v}} ->
        %{id: id, key: k, value: v}
      end)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:transform, batch_params["transform"] || socket.assigns.transform)
     |> assign(:props_entries, props_entries)}
  end

  def handle_event("validate", _params, socket),
    do: {:noreply, socket}

  @impl true
  def handle_event("toggle_transform", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, :mode, mode)}
  end

  @impl true
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

  @impl true
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
      |> Enum.reject(fn %{key: k, value: v} ->
        k in ["", nil] or v in ["", nil]
      end)
      |> Map.new(fn %{key: k, value: v} -> {k, v} end)

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
  end

end
