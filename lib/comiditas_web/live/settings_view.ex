defmodule ComiditasWeb.Live.SettingsView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Template, Util}
  alias ComiditasWeb.Endpoint

  def render(assigns) do
    ComiditasWeb.PageView.render("settings.html", assigns)
  end

  def mount(session, socket) do
    pid = Util.get_pid(session.user.group_id)

    Endpoint.subscribe(Comiditas.templates_user_topic(session.uid))
    tps = GroupServer.templates_of_user(pid, session.uid)

    {:ok, assign(socket, pid: pid, uid: session.uid, templates: tps)}
  end

  def handle_event("multi_select", _value, socket) do
    IO.inspect("multi select")
    {:noreply, socket}
  end

  def handle_event("change", %{"date" => weekday, "meal" => meal, "val" => value}, socket) do
    template = Enum.find(socket.assigns.templates, &(&1.day == String.to_integer(weekday)))
    changeset = Template.changeset(template, Map.put(%{}, meal, value))
    GroupServer.change_template(socket.assigns.pid, changeset)

    {:noreply, socket}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.templates_user_topic(socket.assigns.uid) do
      {:noreply, assign(socket, templates: state.templates)}
    else
      {:noreply, socket}
    end
  end
end
