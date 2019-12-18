defmodule Comiditas do
  @moduledoc """
  Comiditas keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query

  alias Comiditas.Admin.User
  alias Comiditas.{Mealdate, Repo, Template}

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

  def generate_days(n, mealdates, templates, user_id) do
    mds = Enum.filter(mealdates, &(&1.user_id == user_id))
    tps = Enum.filter(templates, &(&1.user_id == user_id))
    generate_days(n, mds, tps)
  end

  def generate_days(n, mealdates, templates) do
    Enum.reduce((n - 1)..0, [], fn x, acc ->
      date = today() |> Timex.shift(days: x)
      [get_day(date, mealdates, templates) | acc]
    end)
  end

  def get_day(date, mealdates, templates) do
    case find_mealdate(date, mealdates) do
      nil ->
        date
        |> find_template(templates)
        |> template_to_mealdate(date)

      md ->
        md
    end
    |> Map.put(:weekday, Timex.weekday(date))
  end

  def template_to_mealdate(template, date) do
    to_map =
      template
      |> Map.from_struct()
      |> Map.drop([:__meta__, :id, :day, :user, :inserted_at, :updated_at])
      |> Map.put(:date, date)
      |> Map.put(:notes, nil)

    struct(Mealdate, to_map)
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

  def get_users(group_id) do
    User
    |> where(group_id: ^group_id)
    |> Repo.all()
  end

  def get_mealdates_of_group(user_ids) do
    Mealdate
    |> where([m], m.date >= ^today())
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
  end

  def get_templates_of_group(user_ids) do
    Template
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
  end
end
