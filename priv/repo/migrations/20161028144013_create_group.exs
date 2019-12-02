defmodule Comiditas.Repo.Migrations.CreateGroup do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string

      timestamps()
    end

  end
end
