defmodule PollsApp.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias PollsApp.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import PollsApp.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(PollsApp.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(PollsApp.Repo, {:shared, self()})
    end

    :ok
  end

  def setup_sandbox(tags) do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(PollsApp.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)
  end


  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
