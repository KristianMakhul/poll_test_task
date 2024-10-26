defmodule PollsApp.Polls do
  import Ecto.Query
  alias PollsApp.{Repo, Poll, Vote}

  @doc """
  Creates a changeset for a new poll using the given attributes.

  ## Example
      iex> attrs = %{"name" => "Best Programming Language"}
      iex> PollsApp.Polls.poll_changeset(attrs)
      %Ecto.Changeset<action: nil, changes: %{name: "Best Programming Language"}, ...>
  """
  def poll_changeset(attrs \\ %{}) do
    Poll.changeset(%Poll{}, attrs)
  end

  @doc """
  Creates a new poll in the database.

  ## Example
      iex> attrs = %{"name" => "Best Food","user_id" => 1, "options" => ["One", "Two"]}
      iex> PollsApp.Polls.create_poll(attrs)
      {:ok, %Poll{name: "Best Food", ...}}
  """
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

  @doc """
  Retrieves a poll by its ID and preloads associated votes.

  ## Example
      iex> PollsApp.Polls.get_poll!(1)
      %Poll{id: 1, name: "Best Programming Language", options: [...], ...}
  """
  def get_poll!(id) do
    Repo.get!(Poll, id)
    |> Repo.preload(:votes)
  end

  @doc """
  Updates an existing poll with new attributes.

  ## Example
      iex> poll = PollsApp.Polls.get_poll!(1)
      iex> PollsApp.Polls.update_poll(poll, %{"name" => "Best Food"})
      {:ok, %Poll{id: 1, name: "Best Food"}, ...}
  """
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a poll from the database.

  ## Example
      iex> poll = PollsApp.Polls.get_poll!(1)
      iex> PollsApp.Polls.delete_poll(poll)
      {:ok, %PollsApp.Poll{__meta__: #Ecto.Schema.Metadata<:deleted, "polls">, id: 1, ...}
  """
  def delete_poll(%Poll{} = poll) do
    Repo.delete(poll)
  end

  @doc """
  Lists all polls along with their authors.

  ## Example
      iex> PollsApp.Polls.list_all_polls_with_authors()
      [{1, "Best Programming Language", "author1"}, {2, "Best Food", "author2"}]
  """
  def list_all_polls_with_authors do
    Poll
    |> Repo.all()
    |> Repo.preload(:user)
    |> Enum.map(fn poll ->
      {poll.id, poll.name, poll.user.username}
    end)
  end

  @doc """
  Retrieves all votes associated with a specific poll by its ID.

  ## Example
      iex> PollsApp.Polls.get_votes_by_poll_id(1)
      [%PollsApp.Vote{...}, %PollsApp.Vote{...}]
  """
  def get_votes_by_poll_id(poll_id) do
    Vote
    |> where([v], v.poll_id == ^poll_id)
    |> Repo.all()
  end

  @doc """
  Calculates the distribution of votes for a specific poll.

  ## Example
      iex> PollsApp.Polls.votes_distribution(1)
      [{"Option A", 10, 50.0}, {"Option B", 10, 50.0}]
  """
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

  @doc """
  Retrieves the options available for a specific poll.

  ## Example
      iex> PollsApp.Polls.get_poll_options(1)
      ["Option A", "Option B"]
  """
  def get_poll_options(poll_id) do
    poll = Repo.get!(Poll, poll_id)
    poll.options || []
  end

  @doc """
  Gets the distribution of votes for all polls along with their authors.

  ## Example
      iex> PollsApp.Polls.polls_votes_distribution()
      %{1 => [{"Option A", 10, 50.0}, {"Option B", 10, 50.0}]}
  """
  def polls_votes_distribution do
    list_all_polls_with_authors()
    |> Enum.map(fn {poll_id, _, _} ->
      {poll_id, votes_distribution(poll_id)}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Simple way to seeds a new poll with the given attributes.

  ## Example
      iex> PollsApp.Polls.seeds_poll(%{"name" => "Best Food","user_id" => 1, "options" => ["One", "Two"]})
      {:ok, %Poll{name: "Best Food", ...}}
  """
  def seeds_poll(attrs) do
    %Poll{}
    |> Poll.changeset(attrs)
    |> Repo.insert()
  end
end
