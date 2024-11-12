defmodule PollsAppWeb.VotesPageTest do
  use PollsAppWeb.ConnCase
  import Phoenix.LiveViewTest
  alias PollsApp.{Accounts, Polls}

  setup %{conn: conn} do
    {:ok, user} =
      Accounts.register_user(%{
        username: "test_user",
        password: "password123"
      })

    {:ok, poll} =
      Polls.seeds_poll(%{
        name: "Sample Poll",
        user_id: user.id,
        options: ["Option A", "Option B", "Option C"]
      })

    conn = log_in_user(conn, user)

    {:ok, conn: conn, user: user, poll: poll}
  end

  test "renders the poll page with options", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    assert render(view) =~ "#{poll.id} #{poll.name}"
    assert render(view) =~ "Option A"
    assert render(view) =~ "Option B"
    assert render(view) =~ "Option C"
  end

  test "user can vote for an option", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    view
    |> element("button", "Option A")
    |> render_click()

    assert render(view) =~ "You voted for: Option A"
  end

  test "prevents voting twice on the same poll", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    view
    |> element("button", "Option A")
    |> render_click()

    refute render(view) =~ "You have already voted in this poll."

    view
    |> element("button", "Option B")
    |> render_click()

    assert render(view) =~ "You have already voted in this poll."
  end

  test "user can see poll results after voting", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    refute render(view) =~ "You voted for: Option A"

    view
    |> element("button", "Option A")
    |> render_click()

    assert render(view) =~ "Result of Poll"
    assert render(view) =~ "You voted for: Option A"
  end

  test "user can exit the poll", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    view
    |> element("button[phx-click=exit_poll]")
    |> render_click()

    assert_redirect(view, "/polls")
  end

  test "user can retract their vote", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    view
    |> element("button", "Option A")
    |> render_click()

    refute render(view) =~ "You didn&#39;t vote yet"

    view
    |> element("button[phx-click=retract_vote]")
    |> render_click()

    assert render(view) =~ "You didn&#39;t vote yet"
  end

  test "disables retract button if no vote", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    assert has_element?(view, "button[disabled=\"disabled\"]", "Retract Vote")
  end

  test "active retract button after vote", %{conn: conn, poll: poll} do
    {:ok, view, _html} = live(conn, "/polls/#{poll.id}")

    assert has_element?(view, "button[disabled=\"disabled\"]", "Retract Vote")

    view
    |> element("button", "Option A")
    |> render_click()

    refute has_element?(view, "button[disabled=\"disabled\"]", "Retract Vote")
  end
end
