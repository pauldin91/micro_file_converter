defmodule CoreWeb.PictureLive.FormComponent do
  use CoreWeb, :live_component

  alias Core.Pictures

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage picture records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="picture-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input picture={@pictures.avatar} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Picture</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{picture: picture} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Pictures.change_picture(picture))
     end)}
  end

  @impl true
  def handle_event("validate", %{"picture" => picture_params}, socket) do
    changeset = Pictures.change_picture(socket.assigns.picture, picture_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"picture" => picture_params}, socket) do
    pictures =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest =
          Path.join([:code.priv_dir(:file_upload_demo), "static", "uploads", Path.basename(path)])

        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.cp!(path, dest)
        {:ok, ~p"/pictures/#{Path.basename(dest)}"}
      end)

    save_picture(socket, socket.assigns.action, picture_params)
  end

  defp save_picture(socket, :edit, picture_params) do
    case Pictures.update_picture(socket.assigns.picture, picture_params) do
      {:ok, picture} ->
        notify_parent({:saved, picture})

        {:noreply,
         socket
         |> put_flash(:info, "Picture updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_picture(socket, :new, picture_params) do
    case Pictures.create_picture(picture_params) do
      {:ok, picture} ->
        notify_parent({:saved, picture})

        {:noreply,
         socket
         |> put_flash(:info, "Picture created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
