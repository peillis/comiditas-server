defmodule Comiditas.Repo do
  use Ecto.Repo,
    otp_app: :comiditas,
    adapter: Ecto.Adapters.Postgres
end
