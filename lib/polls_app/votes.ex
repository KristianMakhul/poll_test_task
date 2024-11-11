defmodule PollsApp.Votes do
  alias PollsApp.{Repo, Vote, Accounts.User}

  @doc """
  Creates a new vote.

  ## Example
      iex> attrs = %{"user_id" => 1, "poll_id" => 2, "option" => "Option A"}
      iex> PollsApp.Votes.create_vote(attrs)
      {:ok,  %PollsApp.Vote{__meta__: #Ecto.Schema.Metadata<:loaded, "votes">, id: 17, user_id: 1, ...}
  """
def create_vote(attrs) do
  %Vote{}
  |> Vote.changeset(attrs)
  |> Repo.insert()
  |> case do
    {:ok, vote} ->
      {:ok, vote}

    {:error, _changeset} ->
      {:error, "An error occurred"}
  end
end

  @doc """
  Deletes a vote.

  ## Example
      iex> attrs = %{"user_id" => 3, "poll_id" => 2, "option" => "Option A"}
      iex> {:ok, vote} = PollsApp.Votes.create_vote(attrs)
      iex> PollsApp.Votes.delete_vote(vote)
      {:ok, %PollsApp.Vote{__meta__: #Ecto.Schema.Metadata<:deleted, "votes">, user_id: 1, poll_id: 2, ...}}
  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Retrieves the vote cast by a user for a specific poll, if any.

  ## Example
      iex> PollsApp.Votes.get_user_vote_for_poll(1, 2)
      "You voted for: Option A"
  """
  def get_user_vote_for_poll(user_id, poll_id) do
    user = Repo.get!(User, user_id)
    |> Repo.preload(:votes)

    Enum.find(user.votes, fn vote -> vote.poll_id == poll_id end)
    |> case do
      nil -> "You didn't vote yet"
      vote -> "You voted for: #{vote.option}"
    end
  end

  @doc """
  Deletes a user's vote for a specific poll.

  ## Example
      iex> PollsApp.Votes.delete_vote(1, 2)
      {:ok,  %PollsApp.Vote{__meta__: #Ecto.Schema.Metadata<:deleted, "votes">,id: 1, user_id:1, ...}
  """
  def delete_vote(user_id, poll_id) do
    vote = Repo.get_by(Vote, user_id: user_id, poll_id: poll_id)

    if vote do
      Repo.delete(vote)
    end
  end
end
