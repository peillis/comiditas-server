defmodule Comiditas.Mealdate do
  use Comiditas.Web, :model

  schema "mealdates" do
    field :date, Ecto.Date
    field :breakfast, :string
    field :lunch, :string
    field :dinner, :string
    belongs_to :user, Comiditas.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :breakfast, :lunch, :dinner])
    |> validate_required([:date, :breakfast, :lunch, :dinner])
  end
end
