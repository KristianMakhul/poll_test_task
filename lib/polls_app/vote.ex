defmodule PollsApp.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    belongs_to(:user, PollsApp.Accounts.User)
    belongs_to(:poll, PollsApp.Poll)
    field(:option, :string)

    timestamps()
  end

  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:user_id, :poll_id, :option])
    |> validate_required([:user_id, :poll_id, :option])
    |> unique_constraint(:poll_id, name: :votes_user_id_poll_id_index)
  end
end
