defmodule Comiditas.Repo.Migrations.Frozen do
  use Ecto.Migration

  def change do
    create table(:frozen) do
      add :date, :date
      add :group_id, references(:groups, on_delete: :delete_all)

      timestamps()
    end
  end
end
