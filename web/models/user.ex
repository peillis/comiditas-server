defmodule Comiditas.User do
  use Comiditas.Web, :model

  alias Comiditas.Template

  schema "users" do
    field :name, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :group, Comiditas.Group
    has_many :templates, Comiditas.Template, on_delete: :delete_all
    has_many :mealdates, Comiditas.Mealdate, on_delete: :delete_all

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :group_id])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def registration_changeset(struct, params) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
    |> set_templates()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end

  defp set_templates(changeset) do
    templates = Enum.map([1, 2, 3, 4, 5, 6, 7], fn(x) ->
      %{day: x, breakfast: "yes", lunch: "yes", dinner: "yes"}
    end)
    changeset |> Ecto.Changeset.put_assoc(:templates, templates)
  end

end
