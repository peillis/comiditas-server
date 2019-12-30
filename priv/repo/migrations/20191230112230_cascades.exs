defmodule Comiditas.Repo.Migrations.Cascades do
  use Ecto.Migration

  def change do
    drop(constraint(:users, :users_group_id_fkey))
    alter table(:users) do
      modify(:group_id, references(:groups, on_delete: :delete_all))
    end

    drop(constraint(:templates, :templates_user_id_fkey))
    alter table(:templates) do
      modify(:user_id, references(:users, on_delete: :delete_all))
    end

    drop(constraint(:mealdates, :mealdates_user_id_fkey))
    alter table(:mealdates) do
      modify(:user_id, references(:users, on_delete: :delete_all))
    end
  end
end
