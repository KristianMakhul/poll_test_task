defmodule PollsApp.Repo do
  use Ecto.Repo,
    otp_app: :polls_app,
    adapter: Ecto.Adapters.Postgres
end
