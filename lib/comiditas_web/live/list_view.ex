defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  @items 15
  @max_items 300

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(session, socket) do
    pid =
      case GroupServer.start_link(session.user.group_id) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    Endpoint.subscribe("user:#{session.user.id}")
    GroupServer.gen_days_of_user(pid, @items, session.user.id)

    {:ok, assign(socket, pid: pid, user_id: session.user.id, list: [])}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + @items

    if len < @max_items do
      GroupServer.gen_days_of_user(socket.assigns.pid, len, socket.assigns.user_id)
    end

    {:noreply, socket}
  end

  def handle_event("multi_select", _value, socket) do
    IO.inspect("multi select")
    {:noreply, socket}
  end

  def handle_event("change", %{"date" => date, "meal" => meal, "val" => val}, socket) do
    date = Util.str_to_date(date)
    GroupServer.change_day(
      socket.assigns.pid,
      socket.assigns.list,
      date,
      String.to_atom(meal),
      val
    )

    {:noreply, socket}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == "user:#{socket.assigns.user_id}" do
      {:noreply, assign(socket, list: state.list)}
    else
      {:noreply, socket}
    end
  end
end
