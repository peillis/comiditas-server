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

    Endpoint.subscribe("totals:#{Comiditas.today}")

    {:ok, assign(socket, pid: pid, totals: %{})}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == "totals:#{Comiditas.today}" do
      {:noreply, assign(socket, list: state.list)}
    else
      {:noreply, socket}
    end
  end
end
