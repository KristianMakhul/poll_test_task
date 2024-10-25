defmodule PollsAppWeb.WelcomePageTest do
  use PollsAppWeb.ConnCase

  import Phoenix.LiveViewTest

  test "renders welcome page with correct content", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")

    assert html =~ "Welcome to the Polling Application!"
    assert html =~ "Create and participate in polls effortlessly."
    assert html =~ "Please note: To cast your vote, you&#39;ll need to register or log in."
  end

  test "clicking the button navigates to existing polls", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert {:error, {:live_redirect, %{to: "/polls", kind: :push}}} == view |> element("a") |> render_click()
  end
end
