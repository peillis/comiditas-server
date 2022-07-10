defmodule Comiditas.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :power_user, :boolean, default: false
    field :root_user, :boolean, default: false
    belongs_to :group, Comiditas.Groups.Group

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :group_id, :power_user, :root_user])
    |> validate_required([:name, :email, :password, :group_id])
    |> foreign_key_constraint(:group_id)
  end
end
