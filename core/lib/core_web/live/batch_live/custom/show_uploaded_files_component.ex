defmodule CoreWeb.Components.UploadComponent do
  use CoreWeb, :live_component
  alias Core.Uploads

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div :for={entry <- @uploads.files.entries} id={"upload-#{entry.ref}"} class="mb-2">
        <div class="flex items-center justify-between p-3 bg-base-200 rounded">
          <div class="flex items-center">
            <div class="text-sm font-medium text-base-content">{entry.client_name}</div>
            <div class="text-sm text-base-content/70 ml-2">
              ({Uploads.format_bytes(entry.client_size)})
            </div>
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
    </div>
    """
  end
end
