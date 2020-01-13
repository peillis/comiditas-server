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

  def handle_event("change", %{"date" => weekday, "meal" => meal, "val" => value}, socket) do
    template = Enum.find(socket.assigns.templates, &(&1.day == String.to_integer(weekday)))
    changeset = Template.changeset(template, Map.put(%{}, meal, value))
    GroupServer.change_template(socket.assigns.pid, changeset)

    {:noreply, socket}
  end

  def handle_event(
        "change",
        %{
          "date-from" => day_from,
          "meal-from" => meal_from,
          "date-to" => day_to,
          "meal-to" => meal_to,
          "val" => value
        },
        socket
      ) do
    GroupServer.change_templates(
      socket.assigns.pid,
      socket.assigns.uid,
      String.to_integer(day_from),
      String.to_atom(meal_from),
      String.to_integer(day_to),
      String.to_atom(meal_to),
      value
    )

    {:noreply, socket}
  end

  def handle_event("multi_select", %{"date" => date, "meal" => meal}, socket) do
    tps =
      Enum.map(socket.assigns.templates, fn x ->
        if x.day == String.to_integer(date) do
          Map.put(x, :multi_select, meal)
        else
          x
        end
      end)

    {:noreply, assign(socket, templates: tps)}
  end

  def handle_event("multi_select", _data, socket) do
    # multi_select clicked twice
    GroupServer.templates_of_user(socket.assigns.pid, socket.assigns.uid)

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
