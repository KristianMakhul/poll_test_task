defmodule PollsApp.PollsTest do
  use PollsApp.DataCase, async: true

  alias PollsApp.{Polls, Repo, Poll, Vote}

  describe "polls" do
    setup do
      {:ok, user} = PollsApp.Accounts.register_user(%{username: "John", password: "123"})
      {:ok, user: user}
    end

    test "creates a poll", %{user: user} do
      attrs = %{
        name: "Favorite language?",
        user_id: user.id,
        options: ["Elixir", "Python", "Ruby"]
      }

      assert {:ok, %Poll{} = poll} = Polls.seeds_poll(attrs)
      assert poll.name == "Favorite language?"
      assert poll.user_id == user.id
      assert poll.options == ["Elixir", "Python", "Ruby"]
    end

    test "returns error when creating poll with small name", %{user: user} do
      attrs = %{name: "F?", user_id: user.id, options: ["Elixir", "Python"]}
      Polls.seeds_poll(attrs)

      assert {:error, _changeset} = Polls.seeds_poll(attrs)
    end

    test "lists all polls with authors", %{user: user} do
      poll_attrs = %{name: "Favorite language?", user_id: user.id, options: ["Elixir", "Python"]}
      Polls.seeds_poll(poll_attrs)

      [{poll_id, poll_name, poll_author}] = Polls.list_all_polls_with_authors()

      assert {poll_id, poll_name, poll_author} == {poll_id, "Favorite language?", "John"}
    end

    test "gets votes distribution for a poll", %{user: user} do
      poll_attrs = %{name: "Favorite drink?", user_id: user.id, options: ["Tea", "Coffee"]}
      {:ok, user2} = PollsApp.Accounts.register_user(%{username: "John1", password: "123"})
      {:ok, user3} = PollsApp.Accounts.register_user(%{username: "John2", password: "123"})
      {:ok, poll} = Polls.seeds_poll(poll_attrs)

      # Create some votes
      Repo.insert!(%Vote{poll_id: poll.id, user_id: user.id, option: "Tea"})
      Repo.insert!(%Vote{poll_id: poll.id, user_id: user2.id, option: "Coffee"})
      Repo.insert!(%Vote{poll_id: poll.id, user_id: user3.id, option: "Tea"})

      distribution = Polls.votes_distribution(poll.id)

      assert distribution == [
               {"Tea", 2, 66.66666666666667},
               {"Coffee", 1, 33.333333333333336}
             ]
    end

    test "deletes a poll", %{user: user} do
      attrs = %{name: "Favorite season?", user_id: user.id, options: ["Winter", "Summer"]}
      {:ok, poll} = Polls.seeds_poll(attrs)

      assert {:ok, %Poll{}} = Polls.delete_poll(poll)
      assert_raise Ecto.NoResultsError, fn -> Polls.get_poll!(poll.id) end
    end

    test "update existing poll", %{user: user} do
      poll_attrs = %{
        name: "Update Me",
        user_id: user.id,
        options: ["Old Option 1", "Old Option 2"]
      }

      {:ok, poll} = Polls.seeds_poll(poll_attrs)

      updated_attrs = %{name: "Updated Poll Name", options: ["New Option 1", "New Option 2"]}

      {:ok, updated_poll} = Polls.update_poll(poll, updated_attrs)

      assert updated_poll.name == "Updated Poll Name"
      assert updated_poll.options == ["New Option 1", "New Option 2"]
    end
  end
end
