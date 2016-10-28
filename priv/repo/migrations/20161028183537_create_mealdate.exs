defmodule Comiditas.Repo.Migrations.CreateMealdate do
  use Ecto.Migration

  def change do
    create table(:mealdates) do
      add :date, :date
      add :breakfast, :string
      add :lunch, :string
      add :dinner, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:mealdates, [:user_id])

  end
end
