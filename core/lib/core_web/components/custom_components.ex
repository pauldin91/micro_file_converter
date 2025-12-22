defmodule CoreWeb.CustomComponents do
  use Phoenix.Component
  import CoreWeb.CoreComponents, only: [button: 1]
  alias Core.Uploads.Formatter

  attr :files, :any, required: true

  def display_uploads(assigns) do
    ~H"""
    <div id="upload-display">
      <div :for={entry <- @files.entries} id={"upload-#{entry.ref}"} class="mb-2">
        <div class="flex items-center justify-between p-3 bg-base-200 rounded">
          <div class="flex items-center">
            <div class="text-sm font-medium text-base-content">{entry.client_name}</div>
            <div class="text-sm text-base-content/70 ml-2">
              ({Formatter.format_bytes(entry.client_size)})
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

  attr :files, :any, required: true

  def drag_n_drop(assigns) do
    ~H"""
    <div class="border-2 border-dashed border-base-300 rounded-lg p-6 mb-4" id="drag-n-drop">
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
          <.live_file_input upload={@files} class="sr-only" />
          <label for={@files.ref} class="cursor-pointer">
            <span class="mt-2 block text-sm font-medium text-base-content">
              Drop files here or click to browse
            </span>
          </label>
        </div>
      </div>
    </div>
    """
  end
end
