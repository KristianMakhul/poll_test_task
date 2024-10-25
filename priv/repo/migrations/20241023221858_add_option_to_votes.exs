defmodule PollsApp.Repo.Migrations.AddOptionToVotes do
  use Ecto.Migration

  def change do
    alter table(:votes) do
      add :option, :string  
    end
  end
end
