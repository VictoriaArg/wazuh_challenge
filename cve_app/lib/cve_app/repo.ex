defmodule CveApp.Repo do
  use Ecto.Repo,
    otp_app: :cve_app,
    adapter: Ecto.Adapters.Postgres
end
