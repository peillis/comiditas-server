defmodule Comiditas.Totals do
  def get_totals(users, date) do
    users
    |> Enum.map(&Map.merge(&1, get_user_meals(&1, date, [:lunch, :dinner])))
    |> Enum.map(&Map.merge(&1, get_user_meals(&1, Timex.shift(date, days: 1), [:breakfast])))
    |> build_totals()
  end

  defp get_user_meals(user, date, fields) do
    date
    |> Comiditas.get_day(user.mds, user.tps)
    |> Map.take(fields)
  end

  defp build_totals(result) do
    Enum.map([:lunch, :dinner, :breakfast], fn meal ->
      {meal,
       Comiditas.values()
       |> Enum.map(&{&1, get_list_of_names(result, meal, &1)})
       |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
  end

  defp get_list_of_names(results, meal, value) do
    results
    |> Enum.filter(&(Map.get(&1, meal) == value))
    |> Enum.map(& &1.name)
  end
end
