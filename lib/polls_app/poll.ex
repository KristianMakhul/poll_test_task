defmodule PollsApp.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field(:name, :string)
    field(:options, {:array, :string})

    belongs_to(:user, PollsApp.Accounts.User)
    has_many(:votes, PollsApp.Vote)

    timestamps()
  end

  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:name, :options, :user_id])
    |> validate_required([:name, :options, :user_id])
    |> validate_length(:name, min: 3)
  end
end
