defmodule CoreWeb.Live.EnsureOwner do
  use CoreWeb, :live_component
  import Phoenix.LiveView
  alias Core.Uploads

  def on_mount(:default, %{"id" => id}, _session, socket) do
    current_user = socket.assigns.current_user

    batch = Uploads.get_batch!(id)

    if batch.user_id == current_user.id do
      {:cont, assign(socket, :batch, batch)}
    else
      {:halt,
       socket
       |> put_flash(:error, "You are not authorized to access this resource")
       |> redirect(to: "/")}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
