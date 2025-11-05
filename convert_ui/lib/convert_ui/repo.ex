defmodule ConvertUi.Repo do
  use Ecto.Repo,
    otp_app: :convert_ui,
    adapter: Ecto.Adapters.Postgres
end
