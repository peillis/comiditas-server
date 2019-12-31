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
    list = GroupServer.gen_days_of_user(pid, @items, session.uid, Comiditas.today())

    {:ok, assign(socket, pid: pid, user_id: session.uid, list: list)}
  end

  def handle_event("view_more", _value, socket) do
    list = socket.assigns.list
    last = Enum.at(list, -1)
    next_date = Timex.shift(last.date, days: 1)
    len = length(list) + @items

    if len < @max_items do
      GroupServer.gen_days_of_user(socket.assigns.pid, @items, socket.assigns.user_id, next_date, list)
    end

    {:noreply, socket}
  end

  def handle_event("multi_select", %{"date" => date, "meal" => meal}, socket) do
    IO.inspect("multi select")
    IO.inspect date
    IO.inspect meal
    day = Enum.find(socket.assigns.list, &(&1.date == Util.str_to_date(date)))
    day = Map.put(day, :multi_select, meal)

    list = Enum.map(socket.assigns.list, fn x ->
      if x.date == Util.str_to_date(date) do
        Map.put(x, :multi_select, meal)
      else
        x
      end
    end)

    # new_list = Util.replace_in_list(day, socket.assigns.list, :date)
    # new_list = Enum.sort_by(new_list, & &1.date)
    # IO.inspect new_list
    {:noreply, assign(socket, list: list)}
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
      socket.assigns.user_id,
      Comiditas.today()
    )
  end
end
