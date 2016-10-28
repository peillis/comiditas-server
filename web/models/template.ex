defmodule Comiditas.Template do
  use Comiditas.Web, :model

  schema "templates" do
    field :day, :integer
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
    |> cast(params, [:day, :breakfast, :lunch, :dinner])
    |> validate_required([:day, :breakfast, :lunch, :dinner])
  end
end
