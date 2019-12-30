defmodule Comiditas.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :password_virtual, :string, virtual: true
    field :password, :string
    field :power_user, :boolean
    field :root_user, :boolean
    belongs_to :group, Comiditas.Admin.Group
    has_many :templates, Comiditas.Template, on_delete: :delete_all
    has_many :mealdates, Comiditas.Mealdate, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :group_id, :power_user, :root_user])
    |> validate_required([:name, :email, :password, :group_id])
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
