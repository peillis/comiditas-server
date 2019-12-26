defmodule ComiditasWeb.Live.TotalsView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  def render(assigns) do
    ComiditasWeb.PageView.render("totals.html", assigns)
  end

  def mount(session, socket) do
    pid =
      case GroupServer.start_link(session.user.group_id) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    date = Comiditas.today()
    Endpoint.subscribe("day:#{date}")
    GroupServer.totals(pid, date)

    zero = %{pack: [], first: [], yes: [], second: []}
    totals = %{lunch: zero, dinner: zero, breakfast: zero}

    {:ok, assign(socket, pid: pid, date: date, totals: totals)}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == "day:#{socket.assigns.date}" do
      {:noreply, assign(socket, totals: state)}
    else
      {:noreply, socket}
    end
  end
end
