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

    Endpoint.subscribe(Comiditas.user_topic(user.id))
    list = GroupServer.gen_days_of_user(pid, @items, user.id)

    socket =
      socket
      |> selector_initial_assign()
      |> assign(pid: pid)
      |> assign(uid: user.id)
      |> assign(list: list)
      |> assign(frozen: false)
      |> assign(today: GroupServer.today(pid))
      |> assign(notes: nil)

    {:ok, socket}
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

  def handle_event("show_notes", %{"date" => date}, socket) do
    {:ok, d} = Date.from_iso8601(date)
    notes =
      socket.assigns.list
      |> Enum.find(& &1.date == d)
      |> Map.get(:notes)

    {:noreply, assign(socket, notes: {date, notes})}
  end

  def handle_event("hide_notes", _, socket) do
    {:noreply, assign(socket, notes: nil)}
  end

  def handle_event("save_notes", %{"notes" => notes}, socket) do
    %{notes: {date, _notes}} = socket.assigns
    change_day(date, socket, %{notes: String.trim(notes)})

    {:noreply, assign(socket, notes: nil)}
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
