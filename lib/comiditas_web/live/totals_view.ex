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
    date = Comiditas.today()

    Endpoint.subscribe(Comiditas.totals_topic(group_id, date))
    GroupServer.totals(pid, date)

    zero =
      Comiditas.values()
      |> Enum.map(&{&1, []})
      |> Enum.into(%{})

    totals = %{lunch: zero, dinner: zero, breakfast: zero}

    {:ok, assign(socket, pid: pid, group_id: group_id, date: date, totals: totals)}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.totals_topic(socket.assigns.group_id, socket.assigns.date) do
      {:noreply, assign(socket, totals: state)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("change_date", value, socket) do
    IO.puts "change_date"
    IO.puts value
    new_date = Timex.shift(socket.assigns.date, days: value)
    Endpoint.subscribe(Comiditas.totals_topic(socket.assigns.group_id, new_date))
    GroupServer.totals(socket.assigns.pid, new_date)

    {:noreply, assign(socket, date: new_date)}
  end
end
