defmodule ComiditasWeb.Live.SettingsView do
  use Phoenix.LiveView

  alias Comiditas.{Accounts, GroupServer, Util}
  alias ComiditasWeb.Components.Selector
  alias ComiditasWeb.Endpoint
  alias ComiditasWeb.Selection

  import ComiditasWeb.Components

  def mount(_params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    pid = Util.get_pid(user.group_id)

    Endpoint.subscribe(Comiditas.templates_user_topic(user.id))

    circles =
      pid
      |> GroupServer.templates_of_user(user.id)
      |> build_circles()

    {:ok, assign(socket, pid: pid, uid: user.id, circles: circles, selected: nil, multi_select_from: nil, selector: %Selector{})}
  end

  defp build_circles(templates) do
    templates
    |> Enum.map(fn t ->
      {t.day, %{
        "breakfast" => t.breakfast,
        "lunch" => t.lunch,
        "dinner" => t.dinner
      }}
    end)
    |> Enum.into(%{})
  end

  def blink(range, r) do
    if Selection.in_range?(range, r) do
      "blink"
    end
  end

  def handle_event("select", %{"meal" => meal, "day" => day} = params, %{assigns: %{multi_select_from: msf}} = socket) when not is_nil(msf) do
    selected = {String.to_integer(day), meal}
    socket =
      case Selection.compare(selected, msf) do
        :gt -> socket
        _ -> assign(socket, multi_select_from: nil)
      end
    {:noreply, assign_selected(socket, params)}
  end

  def handle_event("select", params, socket) do
    {:noreply, assign_selected(socket, params)}
  end

  defp assign_selected(socket, params) do
    %{"meal" => meal, "day" => day, "left" => left, "top" => top} = params
    selected = {String.to_integer(day), meal}

    socket
    |> assign(selected: selected)
    |> assign(selector: %Selector{show: true, left: left, top: top})
  end

  def handle_event("change", %{"val" => value}, socket) do
    %{pid: pid, uid: uid, selected: {day, meal}, circles: circles} = socket.assigns

    GroupServer.change_template(pid, %{uid: uid, day: day, change: %{meal => value}})

    socket =
      socket
      |> assign(circles: put_in(circles, [day, meal], value))
      |> assign(selector: %Selector{})

    {:noreply, socket}
  end

  def handle_event("multi_select", _, socket) do
    socket =
      socket
      |> assign(multi_select_from: socket.assigns.selected)
      |> assign(selector: %Selector{})

    {:noreply, socket}
  end

  def set_range(nil, selected), do: {selected, nil}
  def set_range({r1, nil}, selected) do
    case Selection.compare(selected, r1) do
      :gt -> {r1, selected}
      _ -> nil
    end
  end
  def set_range(_, _), do: nil

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.templates_user_topic(socket.assigns.uid) do
      {:noreply, assign(socket, circles: build_circles(state.templates))}
    else
      {:noreply, socket}
    end
  end
end
