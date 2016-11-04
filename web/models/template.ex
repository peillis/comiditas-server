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

  def get(date_str, user) do
    date = Timex.parse!(date_str, "%F", :strftime)
    weekday = Timex.weekday(date)
    Comiditas.Repo.one(from t in Comiditas.Template,
        where: t.day==^weekday and t.user_id==^user.id)
  end
end
