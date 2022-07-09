defmodule Comiditas.Repo.Migrations.Timezone do
  use Ecto.Migration

  def change do
    alter table(:groups) do
      add :timezone, :string, default: "Europe/Madrid"
    end
  end
end
