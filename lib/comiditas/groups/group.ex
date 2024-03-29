defmodule Comiditas.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    field :timezone, :string
    has_many :users, Comiditas.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :timezone])
    |> validate_required([:name, :timezone])
    |> validate_timezone(:timezone)
  end

  defp validate_timezone(changeset, field, _options \\ []) do
    validate_change(changeset, field, fn _, timezone ->
      if timezone in Timex.timezones() do
        []
      else
        [{field, "Not valid timezone"}]
      end
    end)
  end
end
