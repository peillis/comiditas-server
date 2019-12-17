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

  def find_mealdate(date, mealdates) do
    Enum.find(mealdates, &(&1.date == date))
  end

  def get_templates(user_id) do
    Template
    |> where(user_id: ^user_id)
    |> Repo.all()
  end

  def find_template(date, templates) do
    Enum.find(templates, &(&1.day == Timex.weekday(date)))
  end

  def generate_days(n, mealdates, templates) do
    Enum.reduce((n - 1)..0, [], fn x, acc ->
      date = today() |> Timex.shift(days: x)
      [get_day(date, mealdates, templates) | acc]
    end)
  end

  def get_day(date, mealdates, templates) do
    tpl =
      case find_mealdate(date, mealdates) do
        nil ->
          find_template(date, templates)
          |> Map.put(:id, nil)
          |> Map.put(:notes, nil)

        md ->
          md
      end

    %{
      id: tpl.id,
      date: date,
      breakfast: tpl.breakfast,
      lunch: tpl.lunch,
      dinner: tpl.dinner,
      notes: tpl.notes,
      selected: nil
    }
  end

  def change_day(user_id, date, meal, val, templates) do
    tpl = find_template(date, templates)

    # if !day.notes and day.breakfast == tpl.breakfast and day.lunch == tpl.lunch and
    #      day.dinner == tpl.dinner do
    #   IO.inspect("borra")
    # else
    #   # require IEx; IEx.pry
    #   IO.inspect("guarda")
    # end
  end
end
