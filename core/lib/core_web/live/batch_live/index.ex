defmodule CoreWeb.BatchLive.Index do
  use CoreWeb, :live_view

  alias Core.Uploads
  alias Core.Handlers
  alias Core.Uploads.Batch
  alias Core.Items
  alias Core.Items.Picture

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Uploads.subscribe()
      Phoenix.PubSub.subscribe(Core.PubSub, "batch:processed")
    end

    user = socket.assigns.current_user

    {:ok,
     stream(socket, :batches, Uploads.list_batches_of_user(user.id))
     |> assign(:form, to_form(Items.change_picture(%Picture{})))
     |> assign(:batch_id, nil)
     |> assign(:batch, %Batch{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Batch")
    |> assign(:batch, Uploads.get_batch!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Batch")
    |> assign(:batch, %Batch{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Uploads")
    |> assign(:batch, nil)
  end

  @impl true
  def handle_info({:batch_processed, batch_id}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Processing complete for #{batch_id}")}
  end

  def handle_info({:batch_created, batch}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  def handle_info({:batch_updated, batch}, socket) do
    {:noreply, stream_insert(socket, :batches, batch)}
  end

  def handle_info({:batch_deleted, item}, socket) do
    {:noreply, stream_delete(socket, :batches, item)}
  end

  @impl true
  def handle_info({:batches_purged, count}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "#{count} total batches purged")
     |> stream(:batches, [], reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{user: current_user}} = socket) do
    batch = Uploads.get_batch!(id)

    with {:ok, _} <- Uploads.delete_batch_for_user(batch, current_user) do
      {:noreply, stream_delete(socket, :batches, batch)}
    else
      {:error, :unauthorized} ->
        {:noreply, socket |> put_flash(:error, "Unauthorized access to resource")}

      {:error, _reason} ->
        {:noreply, socket |> put_flash(:error, "Invalid operation")}
    end
  end

  @impl true
  def handle_event("purge", _params, socket) do
    Handlers.purge_user_batches(socket.assigns.current_user.id)

    {
      :noreply,
      socket
      |> stream(:batches, [])
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Uploads of {@current_user.email}
      <:actions>
        <.link patch={~p"/batches/new"}>
          <.icon name="hero-document-plus" class="w-7 h-7" />
        </.link>
      </:actions>

      <:actions>
        <.button
          phx-click="purge"
          data-confirm="Are you sure you want to delete all your batches?"
          class="bg-red-500 hover:bg-red-500"
        >
          <.icon name="hero-trash" class="w-7 h-7" />
        </.button>
      </:actions>
    </.header>

    <.table
      id="batches"
      rows={@streams.batches}
      row_click={fn {_id, batch} -> JS.navigate(~p"/batches/#{batch}") end}
    >
      <:col :let={{_id, batch}} label="Id">{String.slice(batch.id, 0, 8)}</:col>
      <:col :let={{_id, batch}} label="Status">{batch.status}</:col>
      <:action :let={{_id, batch}}>
        <div class="sr-only">
          <.link navigate={~p"/batches/#{batch}"}>Show</.link>
        </div>
      </:action>
      <:action :let={{_id, batch}}>
        <.link href={~p"/download/#{batch.id}"}>
          <.icon name="hero-arrow-down-tray" class="w-5 h-5" />
        </.link>
      </:action>
      <:action :let={{id, batch}}>
        <.link phx-click={JS.push("delete", value: %{id: batch.id}) |> hide("##{id}")}>
          <.icon name="hero-trash" class="w-5 h-5 text-error" />
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action == :new}
      id="batch-modal"
      show
      on_cancel={JS.patch(~p"/batches")}
    >
      <.live_component
        module={CoreWeb.BatchLive.FormComponent}
        id="upload-form"
        batch_id={@batch_id}
        batch={@batch}
        user={@current_user}
      />
    </.modal>
    """
  end
end
