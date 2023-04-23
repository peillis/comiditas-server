defmodule ComiditasWeb.Live.TotalsView do
  use Phoenix.LiveView

  import ComiditasWeb.Components

  alias Comiditas.{Accounts, GroupServer, Util}
  alias ComiditasWeb.Endpoint

  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    pid = Util.get_pid(user.group_id)
    date = GroupServer.today(pid)

    Endpoint.subscribe(Comiditas.totals_topic(user.group_id, date))
    {totals, notes, packs} = GroupServer.totals(pid, date)

    socket =
      socket
      |> assign(
       pid: pid,
       group_id: user.group_id,
       date: date,
       totals: totals,
       people_to_show: [],
       notes_to_show: [],
       today: date,
       power_user: user.power_user,
       notes: notes,
       packs: packs
      )
      |> set_freeze()

    {:ok, socket}
  end

  def handle_info(%{topic: topic, payload: {totals, notes, packs}}, socket) do
    if topic == Comiditas.totals_topic(socket.assigns.group_id, socket.assigns.date) do
      {:noreply, assign(socket, totals: totals, notes: notes, packs: packs)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("change_date", value, socket) do
    new_date = Timex.shift(socket.assigns.date, days: value)
    Endpoint.subscribe(Comiditas.totals_topic(socket.assigns.group_id, new_date))
    GroupServer.totals(socket.assigns.pid, new_date)

    socket =
      socket
      |> assign(date: new_date)
      |> set_freeze()

    {:noreply, assign(socket, date: new_date)}
  end

  def handle_event("show_list", %{"meal" => meal, "index" => index}, socket) do
    list =
      meal
      |> String.to_atom()
      |> then(&Map.get(socket.assigns.totals, &1))
      |> Enum.at(String.to_integer(index))

    {:noreply, assign(socket, people_to_show: list)}
  end

  def handle_event("hide_list", _value, socket) do
    {:noreply, assign(socket, people_to_show: [])}
  end

  def handle_event("show_notes", %{"which" => value}, socket) do
    notes = socket.assigns.notes[String.to_atom(value)]
    {:noreply, assign(socket, notes_to_show: notes)}
  end

  def handle_event("hide_notes", _value, socket) do
    {:noreply, assign(socket, notes_to_show: [])}
  end

  def handle_event("freeze", %{"val" => value}, socket) do
    case value do
      "true" -> GroupServer.unfreeze(socket.assigns.pid)
      "false" -> GroupServer.freeze(socket.assigns.pid)
    end
    {:noreply, set_freeze(socket)}
  end

  defp set_freeze(socket) do
    %{date: date, today: today, power_user: power_user, group_id: group_id} = socket.assigns
    freeze =
      if today == date and power_user do
        Comiditas.frozen?(group_id, date)
      else
        nil
      end

    assign(socket, freeze: freeze)
  end

  defp print_date(date) do
    "#{Timex.day_shortname(Date.day_of_week(date))} #{date.day}"
  end

  defp display_length([]), do: ""
  defp display_length(a), do: length(a)

  defp any_pack?(packs) do
    packs
    |> Map.values()
    |> List.flatten()
    |> Kernel.!=([])
  end
end
