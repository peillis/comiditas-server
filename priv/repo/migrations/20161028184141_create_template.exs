defmodule Comiditas.Repo.Migrations.CreateTemplate do
  use Ecto.Migration

  def change do
    create table(:templates) do
      add :day, :integer
      add :breakfast, :string
      add :lunch, :string
      add :dinner, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:templates, [:user_id])

  end
end
