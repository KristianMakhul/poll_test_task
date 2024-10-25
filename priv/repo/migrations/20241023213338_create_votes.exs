defmodule PollsApp.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :poll_id, references(:polls, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:votes, [:user_id, :poll_id])
  end
end
