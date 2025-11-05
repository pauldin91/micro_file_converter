defmodule ConvertUiWeb.DocumentLive.FormComponent do
  use ConvertUiWeb, :live_component

  alias ConvertUi.Docs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage document records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="document-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:path]} type="text" label="Path" />
        <.input field={@form[:mime_type]} type="text" label="Mime type" />
        <.input field={@form[:uploaded_at]} type="datetime-local" label="Uploaded at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Document</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{document: document} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Docs.change_document(document))
     end)}
  end

  @impl true
  def handle_event("validate", %{"document" => document_params}, socket) do
    changeset = Docs.change_document(socket.assigns.document, document_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"document" => doc_params}, socket) do
    consume_uploaded_entries(socket, :file, fn %{path: temp_path}, _entry ->
      dest = Path.join("priv/static/uploads", Path.basename(temp_path))
      File.cp!(temp_path, dest)
      {:ok, dest}
    end)

    # Save to DB (set `path` to your stored file location)
    Docs.create_document(%{
      name: doc_params["name"],
      path: "uploads/#{Path.basename("btc")}",
      mime_type: "application/pdf",
      uploaded_at: NaiveDateTime.utc_now()
    })

    {:noreply, put_flash(socket, :info, "Uploaded successfully")}
  end

  defp save_document(socket, :edit, document_params) do
    case Docs.update_document(socket.assigns.document, document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_document(socket, :new, document_params) do
    case Docs.create_document(document_params) do
      {:ok, document} ->
        notify_parent({:saved, document})

        {:noreply,
         socket
         |> put_flash(:info, "Document created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def mount(socket) do
    {:ok, allow_upload(socket, :file, accept: :any, max_entries: 1)}
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
