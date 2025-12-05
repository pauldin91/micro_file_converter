defmodule CoreWeb.TransformLive.Index do
  use CoreWeb, :live_view

  alias Core.Transformers
  alias Core.Transformers.Transform

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :transforms, Transformers.list_transforms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Transform")
    |> assign(:transform, Transformers.get_transform!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Transform")
    |> assign(:transform, %Transform{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Transforms")
    |> assign(:transform, nil)
  end

  @impl true
  def handle_info({CoreWeb.TransformLive.FormComponent, {:saved, transform}}, socket) do
    {:noreply, stream_insert(socket, :transforms, transform)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transform = Transformers.get_transform!(id)
    {:ok, _} = Transformers.delete_transform(transform)

    {:noreply, stream_delete(socket, :transforms, transform)}
  end
end
