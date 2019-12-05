defmodule Comiditas.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :group, Comiditas.Admin.Group
    has_many :templates, Comiditas.Template, on_delete: :delete_all
    has_many :mealdates, Comiditas.Mealdate, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :group_id])
    |> validate_required([:name, :email, :password_hash, :group_id])
  end
end
