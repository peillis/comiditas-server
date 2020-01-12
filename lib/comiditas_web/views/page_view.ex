defmodule ComiditasWeb.PageView do
  use ComiditasWeb, :view

  def print_weekday(weekday) do
    case weekday do
      1 -> "Mon"
      2 -> "Tue"
      3 -> "Wed"
      4 -> "Thu"
      5 -> "Fri"
      6 -> "Sat"
      7 -> "Sun"
    end
  end

  def expand_day(day) do
    Enum.map_reduce(["breakfast", "lunch", "dinner"], day, fn x, day ->
      multi_select =
        if day.multi_select == x do
          true
        else
          false
        end

      item = %{
        date: day.date,
        value: Map.get(day, String.to_atom(x)),
        meal: x,
        multi_select: multi_select
      }

      {item, day}
    end)
  end

  def print_day(day, today, frozen) do
    {items, _acc} = expand_day(day)

    Enum.map(items, fn x ->
      if x.date == today and frozen do
      ~e"""
      <td class="buttons frozen">
        <%= circle(x.value, x.date, x.meal, x.multi_select) %>
      </td>
      """
      else
      ~e"""
      <td class="buttons">
        <%= circle(x.value, x.date, x.meal, x.multi_select) %>
      </td>
      """
      end
    end)
  end

  def circle(value, date \\ nil, meal \\ nil, multi_select \\ false) do
    class =
      case multi_select do
        true -> "blink"
        _ -> nil
      end

    ~e"""
    <svg class="<%= class %>" data-date="<%= date %>" data-meal="<%= meal %>" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <circle cx="2em" cy="2em" r="2em" fill="<%= color(value) %>"></circle>
      <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(value) %></text>
    </svg>
    """
  end

  def color("yes"), do: "green"
  def color("no"), do: "red"
  def color("1"), do: "lightskyblue"
  def color("2"), do: "blue"
  def color("pack"), do: "gray"

  def text("yes"), do: "Y"
  def text("no"), do: "N"
  def text("1"), do: "1"
  def text("2"), do: "2"
  def text("pack"), do: "P"

  def print_totals(data, meal) do
    ~e"""
    <%= print_value(data["pack"], meal, "pack") %>
    <%= print_value(data["1"], meal, "1") %>
    <%= print_value(data["yes"], meal, "yes") %>
    <%= print_value(data["2"], meal, "2") %>
    """
  end

  def print_value(count, meal, val) do
    if length(count) > 0 do
      ~e"""
      <td phx-click="show_list" phx-value-meal="<%= meal %>" phx-value-val="<%= val %>"><%= length(count) %></td>
      """
    else
      ~e"""
      <td></td>
      """
    end
  end

  def print_date(date) do
    "#{print_weekday(Timex.weekday(date))} #{Timex.format!(date, "{D}")}"
  end
end
