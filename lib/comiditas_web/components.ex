defmodule ComiditasWeb.Components do
  use Phoenix.Component

  def selector(assigns) do
    ~H"""
    <svg id="selector" display={if @selector.show, do: "inline-block", else: "none"} style={"left: #{@selector.left}px; top: #{@selector.top}px;"} version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <circle cx="6em" cy="6em" r="7em" fill="white" stroke="lightgray" stroke-width="0.1em"></circle>
      <circle phx-click="multi_select" cx="6em" cy="6em" r="1em" fill="lightgray"></circle>
      <circle phx-click="change" phx-value-val="yes" cx="6em" cy="2em" r="2em" fill="green"></circle>
      <circle phx-click="change" phx-value-val="1" cx="2.2em" cy="4.7em" r="2em" fill="lightskyblue"></circle>
      <circle phx-click="change" phx-value-val="2" cx="9.8em" cy="4.7em" r="2em" fill="blue"></circle>
      <circle phx-click="change" phx-value-val="pack" cx="3.6em" cy="9.2em" r="2em" fill="gray"></circle>
      <circle phx-click="change" phx-value-val="no" cx="8.4em" cy="9.2em" r="2em" fill="red"></circle>

      <text phx-click="change" phx-value-val="yes" x="2.3em" y="1.15em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">Y</text>
      <text phx-click="change" phx-value-val="1" x="0.83em" y="2.15em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">1</text>
      <text phx-click="change" phx-value-val="2" x="3.78em" y="2.15em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">2</text>
      <text phx-click="change" phx-value-val="pack" x="1.4em" y="3.94em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">P</text>
      <text phx-click="change" phx-value-val="no" x="3.23em" y="3.94em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700">N</text>
    </svg>
    """
  end

  def circle(assigns) do
    ~H"""
    <svg class="" version="1.1" width="4em" height="4em" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      <circle cx="2em" cy="2em" r="2em" fill={color(@value)}></circle>
      <text x="0.77em" y="1.16em" font-size="2.6em" text-anchor="middle" fill="white" style="font-weight:700"><%= text(@value) %></text>
    </svg>
    """
  end

  def frozen(true, %{date: date}, _meal, today) when date == today, do: "frozen"

  def frozen(true, day, :breakfast, today) do
    tomorrow = Timex.shift(today, days: 1)

    if day.date == tomorrow do
      "frozen"
    end
  end

  def frozen(_, _, _, _), do: nil

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
