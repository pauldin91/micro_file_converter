defmodule CoreWeb.TransformLive.Show do
  use CoreWeb, :live_view

  alias Core.Transformers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:transform, Transformers.get_transform!(id))}
  end

  defp page_title(:show), do: "Show Transform"
  defp page_title(:edit), do: "Edit Transform"
end
