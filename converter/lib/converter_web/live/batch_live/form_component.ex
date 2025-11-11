defmodule ConverterWeb.BatchLive.FormComponent do
  use ConverterWeb, :live_component

  alias Converter.Batches

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage batch records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="batch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:timestamp]} type="datetime-local" label="Timestamp" />
        <.input field={@form[:status]} type="text" label="Status" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Batch</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Batches.change_batch(batch))
     end)}
  end

  @impl true
  def handle_event("validate", %{"batch" => batch_params}, socket) do
    changeset = Batches.change_batch(socket.assigns.batch, batch_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"batch" => batch_params}, socket) do
    save_batch(socket, socket.assigns.action, batch_params)
  end

  defp save_batch(socket, :edit, batch_params) do
    case Batches.update_batch(socket.assigns.batch, batch_params) do
      {:ok, batch} ->
        notify_parent({:saved, batch})

        {:noreply,
         socket
         |> put_flash(:info, "Batch updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_batch(socket, :new, batch_params) do
    case Batches.create_batch(batch_params) do
      {:ok, batch} ->
        notify_parent({:saved, batch})

        {:noreply,
         socket
         |> put_flash(:info, "Batch created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
