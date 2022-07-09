defmodule Comiditas.Repo.Migrations.RootUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :root_user, :boolean, default: false
    end
  end
end
