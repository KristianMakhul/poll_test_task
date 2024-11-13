defmodule PollsApp.VotesTest do
  use PollsApp.DataCase, async: true

  alias PollsApp.{Votes, Polls, Vote}

  setup do
    {:ok, user} = PollsApp.Accounts.register_user(%{username: "John", password: "123"})

    poll_attrs = %{name: "Favorite language?", user_id: user.id, options: ["Elixir", "Python"]}
    {:ok, poll} = Polls.seeds_poll(poll_attrs)

    %{user: user, poll: poll}
  end

  test "create vote", %{user: user, poll: poll} do
    # Arrange
    vote_attrs = %{poll_id: poll.id, user_id: user.id, option: "Elixir"}

    # Act
    {:ok, vote} = Votes.create_vote(vote_attrs)

    assert vote.poll_id == poll.id
    assert vote.user_id == user.id
    assert vote.option == "Elixir"
  end

  test "delete vote", %{user: user, poll: poll} do
    # Arrange
    vote_attrs = %{poll_id: poll.id, user_id: user.id, option: "Elixir"}
    {:ok, vote} = Votes.create_vote(vote_attrs)

    # Act
    assert {:ok, _deleted_vote} = Votes.delete_vote(vote)

    # Assert
    # Verify the vote is deleted
    assert Repo.get(Vote, vote.id) == nil
  end

  test "get user vote for poll when user has voted", %{user: user, poll: poll} do
    # Arrange
    vote_attrs = %{poll_id: poll.id, user_id: user.id, option: "Elixir"}
    Votes.create_vote(vote_attrs)

    # Act
    vote_message = Votes.get_user_vote_for_poll(user.id, poll.id)

    # Assert
    assert vote_message == "You voted for: Elixir"
  end

  test "get user vote for poll when user has not voted", %{user: user, poll: poll} do
    # Act
    # User has not voted yet
    vote_message = Votes.get_user_vote_for_poll(user.id, poll.id)

    # Assert
    assert vote_message == "You didn't vote yet"
  end

  test "delete vote when vote exists", %{user: user, poll: poll} do
    vote_attrs = %{poll_id: poll.id, user_id: user.id, option: "Elixir"}
    {:ok, vote} = Votes.create_vote(vote_attrs)

    Votes.delete_vote(user.id, poll.id)

    assert Repo.get(Vote, vote.id) == nil
  end

  test "delete vote when vote does not exist", %{user: user, poll: poll} do
    result = Votes.delete_vote(user.id, poll.id)

    assert result == nil
  end

  test "get user vote for poll when multiple votes exist", %{user: user, poll: poll} do
    vote_attrs1 = %{poll_id: poll.id, user_id: user.id, option: "Elixir"}
    Votes.create_vote(vote_attrs1)

    Votes.delete_vote(user.id, poll.id)
    vote_attrs2 = %{poll_id: poll.id, user_id: user.id, option: "Python"}

    Votes.create_vote(vote_attrs2)

    vote_message = Votes.get_user_vote_for_poll(user.id, poll.id)
    assert vote_message == "You voted for: #{vote_attrs2.option}"
  end
end
