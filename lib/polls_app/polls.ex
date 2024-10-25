defmodule PollsApp.Polls do
  import Ecto.Query
  alias PollsApp.{Repo, Poll, Vote}

  def poll_changeset(attrs \\ %{}) do
    Poll.changeset(%Poll{}, attrs)
  end

  def create_poll(attrs) do
    existing_poll = Repo.get_by(Poll, name: attrs["name"])

    if existing_poll do
      {:error,
       Ecto.Changeset.add_error(%Ecto.Changeset{}, :name, "Poll with this name already exists.")}
    else
      %Poll{}
      |> Poll.changeset(attrs)
      |> Repo.insert()
    end
  end

  def get_poll!(id) do
    Repo.get!(Poll, id)
    |> Repo.preload(:votes)
  end

  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  def list_all_polls_with_authors do
    Poll
    |> Repo.all()
    |> Repo.preload(:user)
    |> Enum.map(fn poll ->
      {poll.id, poll.name, poll.user.username}
    end)
  end

  def get_votes_by_poll_id(poll_id) do
    Vote
    |> where([v], v.poll_id == ^poll_id)
    |> Repo.all()
  end

  def votes_distribution(poll_id) do
    votes = get_votes_by_poll_id(poll_id)
    options = get_poll_options(poll_id)
    total_votes = length(votes)

    Enum.map(options, fn option ->
      votes_count = Enum.count(votes, fn v -> v.option == option end)
      percentage = if total_votes > 0, do: votes_count * 100 / total_votes, else: 0.0

      {option, votes_count, percentage}
    end)
  end

  def get_poll_options(poll_id) do
    poll = Repo.get!(Poll, poll_id)
    poll.options || []
  end

  def polls_votes_distribution do
    list_all_polls_with_authors()
    |> Enum.map(fn {poll_id, _, _} ->
      {poll_id, votes_distribution(poll_id)}
    end)
    |> Enum.into(%{})
  end

  def seeds_poll(attrs) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end
end
