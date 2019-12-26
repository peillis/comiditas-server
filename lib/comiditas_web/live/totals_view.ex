defmodule ComiditasWeb.Live.TotalsView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  def render(assigns) do
    ComiditasWeb.PageView.render("totals.html", assigns)
  end

  def mount(session, socket) do
    group_id = session.user.group_id
    pid =
      case GroupServer.start_link(group_id) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    date = Comiditas.today()
    Endpoint.subscribe(Comiditas.totals_topic(group_id, date))
    GroupServer.totals(pid, date)

    zero =
      ["pack", "1", "yes", "2"]
      |> Enum.map(&({&1, []}))
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
end
