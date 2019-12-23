defmodule Comiditas.Repo.Migrations.RenamePasswordHash do
  use Ecto.Migration

  def change do
    rename table("users"), :password_hash, to: :password
  end
end
