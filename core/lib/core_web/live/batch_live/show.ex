defmodule CoreWeb.BatchLive.Show do
  use CoreWeb, :live_view

  alias Core.Uploads

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:metadata, Uploads.load_metadata(id))
     |> assign(:batch, Uploads.get_batch!(id))}
  end

  defp page_title(:show), do: "Show Batch"
end
