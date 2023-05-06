defmodule Comiditas.Template do
  use Ecto.Schema
  import Ecto.Changeset

  schema "templates" do
    field :day, :integer
    field :breakfast, :string
    field :lunch, :string
    field :dinner, :string
    belongs_to :user, Comiditas.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:day, :breakfast, :lunch, :dinner, :user_id])
    |> validate_required([:day, :breakfast, :lunch, :dinner, :user_id])
  end

  def create_templates(user) do
    Enum.map(1..7, fn day ->
      %__MODULE__{}
      |> changeset(%{
        day: day,
        breakfast: "no",
        lunch: "no",
        dinner: "no",
        user_id: user.id
      })
    end)
  end
end
