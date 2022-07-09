defmodule Comiditas.Repo.Migrations.FrozenUnique do
  use Ecto.Migration

  def change do
    create unique_index(:frozen, [:group_id, :date])
  end
end
