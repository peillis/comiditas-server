defmodule Comiditas.Totals do

  def get_totals(users, mds, tps, group_id, date) do
    users
    |> Enum.map(fn x ->
      day = Comiditas.get_day(date, mds, tps, x.id)
      Map.merge(x, day)
    end)
    |> build_totals()
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
