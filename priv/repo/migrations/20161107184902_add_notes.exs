defmodule Comiditas.Repo.Migrations.AddNotes do
  use Ecto.Migration

  def change do
    alter table(:mealdates) do
      add :notes, :text
    end
  end
end
