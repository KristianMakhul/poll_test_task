defmodule PollsApp.Votes do
  alias PollsApp.{Repo, Vote, Accounts.User}

  def create_vote(attrs) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  def get_user_vote_for_poll(user_id, poll_id) do
    user = Repo.get!(User, user_id)
    |> Repo.preload(:votes)

    Enum.find(user.votes, fn vote -> vote.poll_id == poll_id end)
    |> case do
      nil -> "You didn't vote yet"
      vote -> "You voted for: #{vote.option}"
    end
  end

  def delete_vote(user_id, poll_id) do
    vote = Repo.get_by(Vote, user_id: user_id, poll_id: poll_id)

    if vote do
      Repo.delete(vote)
    end
  end
end
