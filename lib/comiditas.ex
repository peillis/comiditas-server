defmodule Comiditas do
  @moduledoc """
  Comiditas keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  import Ecto.Query

  alias Comiditas.Groups.Group
  alias Comiditas.Accounts.User
  alias Comiditas.{Frozen, Mealdate, Repo, Template}
  alias ComiditasWeb.Selection

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

  def freeze(group_id, date) do
    Repo.insert(%Frozen{date: date, group_id: group_id})
  end

  def unfreeze(group_id, date) do
    Frozen
    |> where(group_id: ^group_id)
    |> where(date: ^date)
    |> Repo.delete_all()
  end

  def frozen?(group_id, date) do
    case Repo.get_by(Frozen, group_id: group_id, date: date) do
      nil -> false
      _ -> true
    end
  end

  def get_users(group_id) do
    User
    |> where(group_id: ^group_id)
    |> order_by(:id)
    |> Repo.all()
  end

  def get_mealdates_of_users(user_ids, date) do
    Mealdate
    |> where([m], m.date >= ^date)
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
  end

  def get_templates_of_users(user_ids) do
    Template
    |> where([m], m.user_id in ^user_ids)
    |> Repo.all()
    |> Enum.map(&Map.put(&1, :multi_select, false))
  end

  def get_timezone(group_id) do
    Repo.get(Group, group_id).timezone
  end

  # Functions for changing multiple days

  def change_days(list, templates, date_from, meal_from, date_to, meal_to, value) do
    range = {{date_from, meal_from}, {date_to, meal_to}}
    Enum.each(list, fn x ->
      meals =
        ["breakfast", "lunch", "dinner"]
        |> Enum.filter(&Selection.in_range?(range, {x.date, &1}))

      if length(meals) > 0 do
        changeset = build_changeset(x, meals, value)
        template = Enum.find(templates, &(&1.day == changeset.data.weekday))
        save_day(changeset, template)
      end
    end)
  end

  def build_changeset(day, meals, value) do
    change =
      meals
      |> Enum.map(&{&1, value})
      |> Enum.into(%{})

    Mealdate.changeset(day, change)
  end

  # Functions for changing multiple templates

  def change_templates(list, range, value) do
    Enum.each(list, fn x ->
      meals =
        ["breakfast", "lunch", "dinner"]
        |> Enum.filter(&Selection.in_range?(range, {x.day, &1}))

      if length(meals) > 0 do
        change =
          meals
          |> Enum.map(&{&1, value})
          |> Enum.into(%{})

        changeset = Template.changeset(x, change)
        save_template(changeset)
      end
    end)
  end
end
