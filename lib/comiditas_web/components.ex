defmodule ComiditasWeb.Components do
  use Phoenix.Component

  def row(assigns) do
    ~H"""
    <tr class={"weekday-#{@day.weekday}"}>
      <td class="day">
        <%= Timex.day_shortname(@day.weekday) %><br/>
        <strong><%= @day.date.day %></strong>
      </td>
      <.print_day day={@day} today={@today} frozen={@frozen} />
      <td class={"notes #{frozen(@frozen, @day, @today)}"} data-date={@day.date} data-notes={@day.notes}>
        <i class={"material-icons #{if @day.notes != nil, do: "red"}"}>description</i>
      </td>
    </tr>
    """
  end

  def print_day(assigns) do
    %{day: day, today: today, frozen: frozen} = assigns
    {items, _acc} = expand_day(day)

    ~H"""
    <%= for x <- items do %>
    <td class={"buttons #{frozen(frozen, x, today)}"}>
      <svg class={blink(x.multi_select, x.meal)} data-date={x.date} data-meal={x.meal} version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <circle cx="2em" cy="2em" r="2em" fill={color(x.value)}></circle>
        <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(x.value) %></text>
      </svg>
    </td>
    <% end %>
    """
  end

  defp frozen(true, %{date: date}, today) when date == today, do: "frozen"
  defp frozen(true, %{meal: "breakfast"} = item, today) do
    tomorrow = Timex.shift(today, days: 1)
    if item.date == tomorrow do
      "frozen"
    end
  end
  defp frozen(_, _, _), do: nil

  defp blink(multi_select, meal) when multi_select == meal, do: "blink"
  defp blink(_, _), do: nil

  def expand_day(day) do
    Enum.map_reduce(["breakfast", "lunch", "dinner"], day, fn x, day ->
      item = %{
        date: day.date,
        value: Map.get(day, String.to_atom(x)),
        meal: x,
        multi_select: day.multi_select
      }

      {item, day}
    end)
  end

  defp color("yes"), do: "green"
  defp color("no"), do: "red"
  defp color("1"), do: "lightskyblue"
  defp color("2"), do: "blue"
  defp color("pack"), do: "gray"

  defp text("yes"), do: "Y"
  defp text("no"), do: "N"
  defp text("1"), do: "1"
  defp text("2"), do: "2"
  defp text("pack"), do: "P"
end
