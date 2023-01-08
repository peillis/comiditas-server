defmodule ComiditasWeb.Live.ListView do
  use ComiditasWeb.Selector

  alias Comiditas.{Accounts, GroupServer, Mealdate, Util}
  alias ComiditasWeb.Endpoint

  import ComiditasWeb.Components

  @items 15
  @max_items 300

  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    pid = Util.get_pid(user.group_id)
    today = GroupServer.today(pid)

    Endpoint.subscribe(Comiditas.user_topic(user.id))
    list = GroupServer.gen_days_of_user(pid, @items, user.id)

    socket = selector_initial_assign(socket)

    {:ok, assign(socket, pid: pid, uid: user.id, list: list, frozen: false, today: today)}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + @items

    if len < @max_items do
      GroupServer.gen_days_of_user(
        socket.assigns.pid,
        @items,
        socket.assigns.uid,
        socket.assigns.list
      )
    end

    {:noreply, socket}
  end

  def handle_event("change", %{"val" => value}, socket) do
    %{pid: pid, uid: uid, selected: selected, multi_select_from: msf} = socket.assigns
    range =
      if is_nil(msf) do
        {selected, selected}
      else
        {msf, selected}
      end

    GroupServer.change_days(pid, uid, socket.assigns.list, range, value)

    socket =
      socket
      |> assign(multi_select_from: nil)
      |> assign(selector: %Selector{})

    {:noreply, socket}
  end

  def handle_event("notes", %{"date" => date, "notes" => notes}, socket) do
    change_day(date, socket, %{notes: String.trim(notes)})

    {:noreply, socket}
  end

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.user_topic(socket.assigns.uid) do
      {:noreply, assign(socket, list: state.list, frozen: state.frozen)}
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
      socket.assigns.uid
    )
  end
end
