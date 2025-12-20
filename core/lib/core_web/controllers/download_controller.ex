defmodule CoreWeb.DownloadController do
  use CoreWeb, :controller
  alias Core.Storage

  def download(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    dbg(user)

    case Storage.download_batch(id) do
      {:ok, zip_path} ->
        zip_filename = "#{id}.zip"

        conn
        |> put_resp_header("content-disposition", "attachment; filename=\"#{zip_filename}\"")
        |> send_file(200, List.to_string(zip_path))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> text("File not found")
    end
  end
end
