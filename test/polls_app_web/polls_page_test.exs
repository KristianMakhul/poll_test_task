defmodule PollsAppWeb.PollsPageTest do
  use PollsAppWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  alias PollsApp.{Accounts, Polls}

  setup %{conn: conn} do
    {:ok, user} = Accounts.register_user(%{
      username: "test_user",
      password: "password123"
    })

    {:ok, poll} = Polls.seeds_poll(%{
      name: "Sample Poll",
      user_id: user.id,
      options: ["Option A", "Option B", "Option C"]
    })

    conn = log_in_user(conn, user)

    {:ok, conn: conn, user: user, poll: poll}
  end

  test "displays list of polls", %{conn: conn, poll: poll, user: user} do
    {:ok, view, _html} = live(conn, "/polls")

    assert has_element?(view, "h2", "Select a Poll")
    assert has_element?(view, "button", "Create New Poll")
    assert render(view) =~ user.username
    assert render(view) =~ poll.name
  end

  test "open create poll modal", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/polls")

    view |> element("button", "Create New Poll") |> render_click()
    assert render(view) =~ "Poll options (comma separated)"
  end

  test "poll creation with valid data", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/polls")

    view |> element("button", "Create New Poll") |> render_click()

    view
    |> form("form", poll: %{name: "New Poll", options: "Option1,Option2"})
    |> render_submit()

    assert render(view) =~ "Poll successfully created"
    assert render(view) =~ "New Poll"
  end

  test "poll creation with invalid data", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/polls")

    view |> element("button", "Create New Poll") |> render_click()

    view
    |> form("form", poll: %{name: "Incomplete Poll", options: "OnlyOneOption"})
    |> render_submit()

    assert render(view) =~ "Cannot create a poll with only one option."
  end

  test "open delete poll modal", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls")

    view |> element("button", "Delete #{poll.name} Poll") |> render_click()
    assert render(view) =~ "Are you sure you want to delete role: #{poll.name} ?"
  end
end
