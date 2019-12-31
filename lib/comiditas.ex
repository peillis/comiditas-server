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
    Timex.today()
  end

  def totals_topic(group_id, date) do
    "group:#{group_id}-day:#{date}"
  end

  def user_topic(user_id) do
    "user:#{user_id}"
  end

  def templates_user_topic(user_id) do
    "templates-user:#{user_id}"
  end

  def values() do
    ["pack", "1", "yes", "2"]
  end

  def values_all() do
    values() ++ ["no"]
  end

  def find_mealdate(date, mealdates) do
    Enum.find(mealdates, &(&1.date == date))
  end

  def find_template(date, templates) do
    Enum.find(templates, &(&1.day == Timex.weekday(date)))
  end

  def filter(objects, user_id) do
    Enum.filter(objects, &(&1.user_id == user_id))
  end

  def generate_days(n, mealdates, templates, date) do
    Enum.reduce((n - 1)..0, [], fn x, acc ->
      date = Timex.shift(date, days: x)
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
    |> Map.put(:multi_select, false)
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

  def save_day(changeset, tpl) do
    {:ok, day} = Repo.insert_or_update(changeset)

    if !day.notes and day.breakfast == tpl.breakfast and day.lunch == tpl.lunch and
         day.dinner == tpl.dinner do
      Repo.delete(day)
      {:deleted, Map.put(day, :id, nil)}
    else
      case changeset.data.id do
        nil -> {:created, day}
        _ -> {:updated, day}
      end
    end
  end

  def save_template(changeset) do
    Repo.update!(changeset)
  end

  def get_users(group_id) do
    User
    |> where(group_id: ^group_id)
    |> Repo.all()
  end

  def get_mealdates_of_users(user_ids) do
    Mealdate
    |> where([m], m.date >= ^today())
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
  end

  def get_templates_of_users(user_ids) do
    Template
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
  end
end
