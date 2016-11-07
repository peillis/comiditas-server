defmodule Comiditas.Mealdate do
  use Comiditas.Web, :model

  alias Comiditas.Repo
  alias Comiditas.Template
  alias Comiditas.Mealdate

  schema "mealdates" do
    field :date, Ecto.Date
    field :breakfast, :string
    field :lunch, :string
    field :dinner, :string
    field :notes, :binary
    belongs_to :user, Comiditas.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:date, :breakfast, :lunch, :dinner, :notes])
    |> validate_required([:date, :breakfast, :lunch, :dinner])
  end

  def get(date_str, user) do
    Repo.one(from m in Mealdate,
        where: m.date==^date_str and m.user_id==^user.id)
  end

  # gets the mealdate or returns a Mealdate from the template
  def get_or_template(date_str, user) do
    case get(date_str, user) do
      nil ->
        date = Timex.parse!(date_str, "%F", :strftime)
        weekday = Timex.weekday(date)
        template = Repo.one(from t in Template,
            where: t.day==^weekday and t.user_id==^user.id)
        %Mealdate{
          breakfast: template.breakfast,
          lunch: template.lunch,
          dinner: template.dinner,
          date: Ecto.Date.cast!(date_str),
          user_id: user.id
        }
      mealdate -> mealdate
    end
  end
end
