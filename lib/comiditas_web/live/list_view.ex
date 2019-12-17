defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    user_id = 5

    pid =
      case GroupServer.start_link(user_id) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
      end

    Endpoint.subscribe("user:#{user_id}")
    GroupServer.get_days_of_user(pid, 10, user_id)

    {:ok, assign(socket, deploy_step: "Ready!", pid: pid, user_id: user_id, list: [])}
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + 10

    list =
      if len < 300 do
        GroupServer.get_days_of_user(socket.assigns.pid, len, socket.assigns.user_id)
      else
        socket.assigns.list
      end

    {:noreply, assign(socket, list: list)}
  end

  def handle_event("multi_select", _value, socket) do
    IO.inspect("multi select")
    {:noreply, socket}
  end

  def handle_event("change", %{"date" => date, "meal" => meal, "val" => val}, socket) do
    IO.inspect("#{date} #{meal} #{val}")
    user_id = socket.assigns.user_id
    date = Util.str_to_date(date)
    templates = []
    Comiditas.change_day(user_id, date, meal, val, templates)

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
