defmodule CoreWeb.BatchLive.FormComponent do
  use CoreWeb, :live_component

  alias Core.Uploads
  alias Core.Items

  @impl true
  def update(%{batch: batch} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Uploads.change_batch(batch))
     end)
     |> allow_upload(:files,
       accept: :any,
       max_entries: 10,
       max_file_size: 50_000_000
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        File Upload Form
        <:subtitle>Use this form to manage batch records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="batch-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="border-2 border-dashed border-base-300 rounded-lg p-6 mb-4">
          <div class="text-center">
            <svg
              class="mx-auto h-12 w-12 text-base-content/40"
              stroke="currentColor"
              fill="none"
              viewBox="0 0 48 48"
            >
              <path
                d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              />
            </svg>
            <div class="mt-4">
              <.live_file_input upload={@uploads.files} class="sr-only" />
              <label for={@uploads.files.ref} class="cursor-pointer">
                <span class="mt-2 block text-sm font-medium text-base-content">
                  Drop files here or click to browse
                </span>
              </label>
            </div>
          </div>
        </div>

        <div :for={entry <- @uploads.files.entries} id={"upload-#{entry.ref}"} class="mb-2">
          <div class="flex items-center justify-between p-3 bg-base-200 rounded">
            <div class="flex items-center">
              <div class="text-sm font-medium text-base-content">{entry.client_name}</div>
              <div class="text-sm text-base-content/70 ml-2">({format_bytes(entry.client_size)})</div>
            </div>

            <.button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              class="text-error hover:text-error/80"
            >
              ✕
            </.button>
          </div>

          <div class="w-full bg-base-300 rounded-full h-2 mt-2">
            <div class="bg-primary h-2 rounded-full" style={"width: #{entry.progress}%"}></div>
          </div>
        </div>

        <div :for={err <- upload_errors(@uploads.files)} class="text-error text-sm mb-2">
          {error_to_string(err)}
        </div>

        <:actions>
          <.button
            type="submit"
            disabled={@uploads.files.entries == [] or @processing}
            class="btn btn-primary w-full"
          >
            {if @processing, do: "Processing...", else: "Upload Files"}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def handle_event("validate", params, socket) do
    batch_params = params["batch"] || %{}
    changeset = Uploads.change_batch(socket.assigns.batch, batch_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", _params, socket) do
    upload_dir = Application.fetch_env!(:core, :uploads_dir)

    {:ok, batch} = Uploads.create_batch(%{status: "pending"})

    uploaded_files =
      consume_uploaded_entries(socket, :files, fn %{path: path}, entry ->
        dest = Path.join([upload_dir, batch.id, entry.client_name])

        File.mkdir_p!(Path.dirname(dest))
        File.cp!(path, dest)

        {:ok, _picture} =
          Items.create_picture(%{
            batch_id: batch.id,
            transform: "rotation_90",
            name: entry.client_name,
            size: File.stat!(dest).size
          })

        {:ok, %{path: dest, client_name: entry.client_name, client_type: entry.client_type}}
      end)

    if uploaded_files != [] do
      metadata = Uploads.save_files(batch.id, uploaded_files)

      pid = self()

      spawn(fn ->
        Process.sleep(5000)
        send(pid, {:processing_complete, batch.id})
      end)

      {:noreply,
       socket
       |> assign(:batch_id, batch.id)
       |> assign(:metadata, metadata)
       |> assign(:uploaded_files, uploaded_files)
       |> assign(:processing, true)}
    else
      {:noreply, socket}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp format_bytes(bytes) when is_integer(bytes) do
    cond do
      bytes >= 1_073_741_824 -> "#{Float.round(bytes / 1_073_741_824, 2)} GB"
      bytes >= 1_048_576 -> "#{Float.round(bytes / 1_048_576, 2)} MB"
      bytes >= 1024 -> "#{Float.round(bytes / 1024, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  defp format_bytes(_), do: "Unknown"

  defp error_to_string(:too_large), do: "File is too large (max 50MB)"
  defp error_to_string(:too_many_files), do: "Too many files (max 10)"
  defp error_to_string(:not_accepted), do: "File type not accepted"
  defp error_to_string(_), do: "Upload error"
end
