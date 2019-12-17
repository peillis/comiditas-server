defmodule ComiditasWeb.PageView do
  use ComiditasWeb, :view

  def circle(value, date, meal, selected) do
    ~e"""
    <td class="circle">
      <svg class="buttons" data-date="<%= date %>" data-meal="<%= meal %>" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
        <circle cx="2em" cy="2em" r="2em" fill="<%= color(value) %>"></circle>
        <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(value) %></text>
      </svg>
    </td>
    """
  end

  def color("yes"), do: "green"
  def color("no"), do: "red"
  def color("1"), do: "lightskyblue"
  def color("2"), do: "blue"
  def color("pack"), do: "lightgray"
  def text("yes"), do: "Y"
  def text("no"), do: "N"
  def text("1"), do: "1"
  def text("2"), do: "2"
  def text("pack"), do: "P"
end
