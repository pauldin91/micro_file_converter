defmodule CoreWeb.TransformLive.FormComponent do
  use CoreWeb, :live_component

  alias Core.Transformers

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage transform records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="transform-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:guid]} type="text" label="Guid" />
        <.input field={@form[:type]} type="text" label="Type" />
        <.input field={@form[:exec]} type="checkbox" label="Exec" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Transform</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{transform: transform} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Transformers.change_transform(transform))
     end)}
  end

  @impl true
  def handle_event("validate", %{"transform" => transform_params}, socket) do
    changeset = Transformers.change_transform(socket.assigns.transform, transform_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transform" => transform_params}, socket) do
    save_transform(socket, socket.assigns.action, transform_params)
  end

  defp save_transform(socket, :edit, transform_params) do
    case Transformers.update_transform(socket.assigns.transform, transform_params) do
      {:ok, transform} ->
        notify_parent({:saved, transform})

        {:noreply,
         socket
         |> put_flash(:info, "Transform updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transform(socket, :new, transform_params) do
    case Transformers.create_transform(transform_params) do
      {:ok, transform} ->
        notify_parent({:saved, transform})

        {:noreply,
         socket
         |> put_flash(:info, "Transform created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
