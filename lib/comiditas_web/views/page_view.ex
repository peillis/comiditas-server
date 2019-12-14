defmodule ComiditasWeb.PageView do
  use ComiditasWeb, :view

  def circle(value, date, meal, selected) do
    if meal == selected do
      ~e"""
      <td class="selector">
        <svg id="last" version="1.1" width="4em" height="4em" style="z-index: 2; overflow: visible" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <circle cx="2em" cy="2em" r="2em" fill="white"></circle>
          <circle cx="2em" cy="-2em" r="2em" fill="green"></circle>
          <circle cx="-1.8em" cy="0.7em" r="2em" fill="lightskyblue"></circle>
          <circle cx="5.8em" cy="0.7em" r="2em" fill="blue"></circle>
          <circle cx="-0.4em" cy="5.2em" r="2em" fill="lightgray"></circle>
          <circle cx="4.4em" cy="5.2em" r="2em" fill="red"></circle>
          <text x="-0.70em" y="0.63em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">1</text>
          <text x="2.25em" y="0.63em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">2</text>
          <text x="0.77em" y="-0.35em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">Y</text>
          <text x="-0.15em" y="2.37em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">P</text>
          <text x="1.7em" y="2.37em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">N</text>
        </svg>
      </td>
      """
    else
      ~e"""
      <td class="circle">
        <svg phx-click="select" phx-value-date="<%= date %>" phx-value-meal="<%= meal %>" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
          <circle cx="2em" cy="2em" r="2em" fill="<%= color(value) %>"></circle>
          <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(value) %></text>
        </svg>
      </td>
      """
    end
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
