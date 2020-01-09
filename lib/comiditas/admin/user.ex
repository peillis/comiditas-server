defmodule Comiditas.Admin.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Comiditas

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
    |> validate_format(:email, ~r/@/)
    |> validate_last_power_user()
    |> unique_constraint(:email)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  defp validate_last_power_user(
         %Ecto.Changeset{valid?: true, changes: %{power_user: false}} = changeset
       ) do
    validate_change(changeset, :power_user, fn :power_user, power_user ->
      users = Comiditas.get_users(changeset.data.group_id)
      if Enum.count(users, &(&1.power_user == true)) < 2 do
        [power_user: "This is the last power user."]
      else
        []
      end
    end)
  end

  defp validate_last_power_user(changeset), do: changeset
end
