defmodule CoreWeb.PictureLive.Index do
  use CoreWeb, :live_view

  alias Core.Pictures
  alias Core.Pictures.Picture

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :pictures, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 2)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Picture")
    |> assign(:picture, Pictures.get_picture!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Picture")
    |> assign(:picture, %Picture{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Pictures")
    |> assign(:picture, nil)
  end

  @impl true
  def handle_info({CoreWeb.PictureLive.FormComponent, {:saved, picture}}, socket) do
    {:noreply, stream_insert(socket, :pictures, picture)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    picture = Pictures.get_picture!(id)
    {:ok, _} = Pictures.delete_picture(picture)

    {:noreply, stream_delete(socket, :pictures, picture)}
  end
end
