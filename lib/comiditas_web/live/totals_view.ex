defmodule ComiditasWeb.Live.TotalsView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  def render(assigns) do
    ComiditasWeb.PageView.render("totals.html", assigns)
  end

  def mount(session, socket) do
    group_id = session.user.group_id
    pid = Util.get_pid(group_id)
    date = GroupServer.today(pid)
    frozen = Comiditas.frozen?(group_id, date)
    power_user = session.user.power_user

    Endpoint.subscribe(Comiditas.totals_topic(group_id, date))
    totals = GroupServer.totals(pid, date)

    {:ok,
     assign(socket,
       pid: pid,
       group_id: group_id,
       date: date,
       totals: totals,
       list: [],
       notes: [],
       today: date,
       frozen: frozen,
       power_user: power_user
     )}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.totals_topic(socket.assigns.group_id, socket.assigns.date) do
      {:noreply, assign(socket, totals: state)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("change_date", value, socket) do
    new_date = Timex.shift(socket.assigns.date, days: value)
    Endpoint.subscribe(Comiditas.totals_topic(socket.assigns.group_id, new_date))
    GroupServer.totals(socket.assigns.pid, new_date)

    {:noreply, assign(socket, date: new_date)}
  end

  def handle_event("show_list", %{"meal" => meal, "val" => value}, socket) do
    list = socket.assigns.totals[String.to_atom(meal)][value]
    {:noreply, assign(socket, list: list)}
  end

  def handle_event("hide_list", _value, socket) do
    {:noreply, assign(socket, list: [])}
  end

  def handle_event("show_notes", %{"notes" => value}, socket) do
    notes = socket.assigns.totals[String.to_atom(value)]
    {:noreply, assign(socket, notes: notes)}
  end

  def handle_event("hide_notes", _value, socket) do
    {:noreply, assign(socket, notes: [])}
  end

  def handle_event("freeze", _value, socket) do
    GroupServer.freeze(socket.assigns.pid)
    {:noreply, assign(socket, frozen: true)}
  end

  def handle_event("unfreeze", _value, socket) do
    GroupServer.unfreeze(socket.assigns.pid)
    {:noreply, assign(socket, frozen: false)}
  end
end
