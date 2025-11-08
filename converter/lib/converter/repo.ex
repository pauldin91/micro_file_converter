defmodule Converter.Repo do
  use Ecto.Repo,
    otp_app: :converter,
    adapter: Ecto.Adapters.Postgres
end
