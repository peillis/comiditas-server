defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  alias Comiditas.{GroupServer, Mealdate, Util}
  alias ComiditasWeb.Endpoint

  @items 15
  @max_items 300

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(session, socket) do
    pid = Util.get_pid(session.user.group_id)

    Endpoint.subscribe(Comiditas.user_topic(session.uid))
    list = GroupServer.gen_days_of_user(pid, @items, session.uid)

    {:ok, assign(socket, pid: pid, user_id: session.uid, list: list)}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + @items

    if len < @max_items do
      GroupServer.gen_days_of_user(
        socket.assigns.pid,
        @items,
        socket.assigns.user_id,
        socket.assigns.list
      )
    end

    {:noreply, socket}
  end

  def handle_event("multi_select", %{"date" => date, "meal" => meal}, socket) do
    list =
      Enum.map(socket.assigns.list, fn x ->
        if x.date == Util.str_to_date(date) do
          Map.put(x, :multi_select, meal)
        else
          x
        end
      end)

    {:noreply, assign(socket, list: list)}
  end

  def handle_event(
        "multi_select",
        %{
          "date-from" => _date_from,
          "meal-from" => _meal_from,
          "date-to" => _date_to,
          "meal-to" => _meal_to
        },
        socket
      ) do
    # multi_select clicked twice
    GroupServer.gen_days_of_user(
      socket.assigns.pid,
      length(socket.assigns.list),
      socket.assigns.user_id
    )

    {:noreply, socket}
  end

  def handle_event(
        "change",
        %{
          "date-from" => date_from,
          "meal-from" => meal_from,
          "date-to" => date_to,
          "meal-to" => meal_to,
          "val" => value
        },
        socket
      ) do
    GroupServer.change_days(
      socket.assigns.pid,
      socket.assigns.user_id,
      socket.assigns.list,
      Util.str_to_date(date_from),
      String.to_atom(meal_from),
      Util.str_to_date(date_to),
      String.to_atom(meal_to),
      value
    )

    {:noreply, socket}
  end

  def handle_event("change", %{"date" => date, "meal" => meal, "val" => value}, socket) do
    change_day(date, socket, Map.put(%{}, meal, value))

    {:noreply, socket}
  end

  def handle_event("notes", %{"date" => date, "notes" => notes}, socket) do
    change_day(date, socket, %{notes: String.trim(notes)})

    {:noreply, socket}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.user_topic(socket.assigns.user_id) do
      {:noreply, assign(socket, list: state.list)}
    else
      {:noreply, socket}
    end
  end

  defp change_day(date, socket, change) do
    day = Enum.find(socket.assigns.list, &(&1.date == Util.str_to_date(date)))
    changeset = Mealdate.changeset(day, change)
    GroupServer.change_day(socket.assigns.pid, changeset)

    GroupServer.gen_days_of_user(
      socket.assigns.pid,
      length(socket.assigns.list),
      socket.assigns.user_id
    )
  end
end
