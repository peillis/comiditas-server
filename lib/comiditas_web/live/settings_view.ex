defmodule ComiditasWeb.Live.SettingsView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Util}
  alias ComiditasWeb.Endpoint

  @items 15
  @max_items 300

  def render(assigns) do
    ComiditasWeb.PageView.render("settings.html", assigns)
  end

  def mount(session, socket) do
    pid = Util.get_pid(session.user.group_id)

    Endpoint.subscribe(Comiditas.templates_user_topic(session.uid))
    tps = GroupServer.templates_of_user(pid, session.uid)

    {:ok, assign(socket, pid: pid, user_id: session.uid, templates: tps)}
  end

  # def handle_event("multi_select", _value, socket) do
  #   IO.inspect("multi select")
  #   {:noreply, socket}
  # end

  # def handle_event("change", %{"date" => date, "meal" => meal, "val" => value}, socket) do
  #   change_day(date, socket, Map.put(%{}, meal, value))

  #   {:noreply, socket}
  # end

  # def handle_info(%{topic: topic, payload: state}, socket) do
  #   if topic == Comiditas.user_topic(socket.assigns.user_id) do
  #     {:noreply, assign(socket, list: state.list)}
  #   else
  #     {:noreply, socket}
  #   end
  # end

  # defp change_day(date, socket, change) do
  #   day = Enum.find(socket.assigns.list, &(&1.date == Util.str_to_date(date)))
  #   changeset = Mealdate.changeset(day, change)
  #   GroupServer.change_day(socket.assigns.pid, changeset)
  #   GroupServer.gen_days_of_user(
  #     socket.assigns.pid,
  #     length(socket.assigns.list),
  #     socket.assigns.user_id
  #   )
  # end
end
