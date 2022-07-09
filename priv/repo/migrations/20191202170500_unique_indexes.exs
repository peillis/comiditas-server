defmodule Comiditas.Repo.Migrations.UniqueIndexes do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:group_id, :email])
    create unique_index(:templates, [:user_id, :day])
    create unique_index(:mealdates, [:user_id, :date])
  end
end
