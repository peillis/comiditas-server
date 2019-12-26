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

  def circle(value, date, meal) do
    ~e"""
    <svg class="buttons" data-date="<%= date %>" data-meal="<%= meal %>" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <%= circle_and_text(value) %>
    </svg>
    """
  end

  def circle(value) do
    ~e"""
    <svg class="buttons" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <%= circle_and_text(value) %>
    </svg>
    """
  end

  def circle_and_text(value) do
    ~e"""
    <circle cx="2em" cy="2em" r="2em" fill="<%= color(value) %>"></circle>
    <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(value) %></text>
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

  def print_totals(meal) do
    ~e"""
    <td><%= print_value(meal.pack) %></td>
    <td><%= print_value(meal.first) %></td>
    <td><%= print_value(meal.yes) %></td>
    <td><%= print_value(meal.second) %></td>
    """
  end

  def print_value(val) do
    if length(val) > 0, do: length(val), else: nil
  end
end
