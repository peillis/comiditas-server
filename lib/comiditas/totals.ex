defmodule Comiditas.Totals do
  def get_totals(users, date) do
    today = Enum.map(users, &get_day(&1, date, [:lunch, :dinner, :notes]))
    tomorrow = Enum.map(users, &get_day(&1, Timex.shift(date, days: 1), [:breakfast, :lunch, :dinner, :notes]))
    %{
      lunch: get_meal_totals(:lunch, today),
      dinner: get_meal_totals(:dinner, today),
      breakfast: get_meal_totals(:breakfast, tomorrow),
      notes: get_notes(today),
      notes_tomorrow: get_notes(tomorrow),
      packs: %{
        "breakfast" => get_meal_totals(:breakfast, tomorrow)["pack"],
        "lunch" => get_meal_totals(:lunch, tomorrow)["pack"],
        "dinner" => get_meal_totals(:dinner, tomorrow)["pack"]
      }
    }
  end

  def get_day(user, date, fields) do
    date
    |> Comiditas.get_day(user.mds, user.tps)
    |> Map.take(fields)
    |> Map.merge(%{name: user.name})
  end

  def get_meal_totals(meal, list) do
    Comiditas.values()
    |> Enum.map(&{&1, get_list_of_names(&1, list, meal)})
    |> Enum.into(%{})
  end

  def get_list_of_names(value, list, meal) do
    list
    |> Enum.filter(& &1[meal] == value)
    |> Enum.map(& &1.name)
  end

  def get_notes(list) do
    list
    |> Enum.filter(& &1.notes != nil)
    |> Enum.map(&{&1.name, &1.notes})
  end

end
