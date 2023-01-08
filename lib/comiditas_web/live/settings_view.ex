defmodule ComiditasWeb.Live.SettingsView do
  use Phoenix.LiveView

  alias Comiditas.{Accounts, GroupServer, Selection, Util}
  alias ComiditasWeb.Components.Selector
  alias ComiditasWeb.Endpoint

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

  def handle_event("change", %{"val" => value}, socket) do
    %{pid: pid, uid: uid, selected: selected, multi_select_from: msf} = socket.assigns
    range =
      if is_nil(msf) do
        {selected, selected}
      else
        {msf, selected}
      end

    GroupServer.change_templates(pid, uid, range, value)

    socket =
      socket
      |> assign(multi_select_from: nil)
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

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.templates_user_topic(socket.assigns.uid) do
      {:noreply, assign(socket, circles: build_circles(state.templates))}
    else
      {:noreply, socket}
    end
  end

  defp assign_selected(socket, params) do
    %{"meal" => meal, "day" => day, "left" => left, "top" => top} = params
    selected = {String.to_integer(day), meal}

    socket
    |> assign(selected: selected)
    |> assign(selector: %Selector{show: true, left: left, top: top})
  end

end
