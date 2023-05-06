defmodule Comiditas.Totals do
  def get_totals(users, date) do
    today = Enum.map(users, &get_day(&1, date, [:lunch, :dinner, :notes]))

    tomorrow =
      Enum.map(
        users,
        &get_day(&1, Timex.shift(date, days: 1), [:breakfast, :lunch, :dinner, :notes])
      )

    {
      # totals
      %{
        lunch: get_meal_totals(:lunch, today),
        dinner: get_meal_totals(:dinner, today),
        breakfast: get_meal_totals(:breakfast, tomorrow)
      },
      # notes
      %{
        today: get_notes(today),
        tomorrow: get_notes(tomorrow)
      },
      # packs
      %{
        breakfast: get_list_of_names("pack", tomorrow, :breakfast),
        lunch: get_list_of_names("pack", tomorrow, :lunch),
        dinner: get_list_of_names("pack", tomorrow, :dinner)
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
    Enum.map(Comiditas.values(), &get_list_of_names(&1, list, meal))
  end

  def get_list_of_names(value, list, meal) do
    list
    |> Enum.filter(&(&1[meal] == value))
    |> Enum.map(& &1.name)
  end

  def get_notes(list) do
    list
    |> Enum.filter(&(&1.notes != nil))
    |> Enum.map(&{&1.name, &1.notes})
  end
end
