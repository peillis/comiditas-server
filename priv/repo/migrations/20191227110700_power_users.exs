defmodule Comiditas.Repo.Migrations.PowerUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :power_user, :boolean, default: false
    end
  end
end
