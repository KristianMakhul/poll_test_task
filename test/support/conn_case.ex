defmodule PollsAppWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionalities to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction that resets at the beginning
  of the test, unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      @endpoint PollsAppWeb.Endpoint

      use PollsAppWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import PollsAppWeb.ConnCase
    end
  end

  setup tags do
    PollsApp.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def log_in_user(conn, user) do
    token = PollsApp.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end
end
