defmodule Comiditas do
  @moduledoc """
  Comiditas keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query

  alias Comiditas.Mealdate
  alias Comiditas.Repo
  alias Comiditas.Template

  def today() do
    Timex.today() |> Timex.shift(months: -3)
  end

  def get_mealdates(user_id) do
    Mealdate
    |> where([m], m.date >= ^today())
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def get_templates(user_id) do
    Template
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def generate_dates(n, mealdates, templates) do
    Enum.reduce(n-1..0, [], fn(x, acc) ->
      date = today() |> Timex.shift(days: x)
      [get_date(date, mealdates, templates) | acc]
    end)
  end

  def get_date(date, mealdates, templates) do
    case Enum.find(mealdates, fn x -> x.date == date end) do
      nil ->
        get_date_from_templates(date, templates)
      md ->
        %{
          date: date,
          breakfast: md.breakfast,
          lunch: md.lunch,
          dinner: md.dinner,
          notes: md.notes,
          selected: 0
        }
    end
  end

  def get_date_from_templates(date, templates) do
    tpl = Enum.find(templates, fn x -> x.day == Timex.weekday(date) end)
    %{
      date: date,
      breakfast: tpl.breakfast,
      lunch: tpl.lunch,
      dinner: tpl.dinner,
      notes: nil,
      selected: 0
    }
  end
end
