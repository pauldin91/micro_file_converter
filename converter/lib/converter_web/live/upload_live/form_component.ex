defmodule ConverterWeb.UploadLive.FormComponent do
  use ConverterWeb, :live_component

  alias Converter.Documents

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage upload records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="upload-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.live_file_input upload={@uploads.files} />
        <:actions>
          <.button type="submit" phx-disable-with="Saving...">Save Upload</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{upload: upload} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Documents.change_upload(upload))
     end)}
  end

  @impl true
  def handle_event("validate", %{"upload" => upload_params}, socket) do
    changeset = Documents.change_upload(socket.assigns.upload, upload_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"upload" => upload_params}, socket) do
    save_upload(socket, socket.assigns.action, upload_params)
  end

  defp save_upload(socket, :edit, upload_params) do
    case Documents.update_upload(socket.assigns.upload, upload_params) do
      {:ok, upload} ->
        notify_parent({:saved, upload})

        {:noreply,
         socket
         |> put_flash(:info, "Upload updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_upload(socket, :new, upload_params) do
    case Documents.create_upload(upload_params) do
      {:ok, upload} ->
        notify_parent({:saved, upload})

        {:noreply,
         socket
         |> put_flash(:info, "Upload created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
