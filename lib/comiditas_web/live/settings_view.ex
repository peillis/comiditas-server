defmodule ComiditasWeb.Live.SettingsView do
  use Phoenix.LiveView

  alias Comiditas.{Accounts, GroupServer, Util}
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
      |> Enum.map(fn t ->
        {t.day, %{
          "breakfast" => t.breakfast,
          "lunch" => t.lunch,
          "dinner" => t.dinner
        }}
      end)
      |> Enum.into(%{})

    {:ok, assign(socket, pid: pid, uid: user.id, circles: circles, selected: nil, range: {{1, "lunch"}, {4, "dinner"}})}
  end

  def blink(range, r) do
    if Selection.in_range?(range, r) do
      "blink"
    end
  end

  def handle_event("select", %{"meal" => meal, "day" => day}, socket) do
    {:noreply, assign(socket, selected: {String.to_integer(day), meal})}
  end

  def handle_event("change", %{"val" => value}, socket) do
    %{pid: pid, uid: uid, selected: {day, meal}, circles: circles} = socket.assigns

    GroupServer.change_template(pid, %{uid: uid, day: day, change: %{meal => value}})
    circles = put_in(circles, [day, meal], value)

    {:noreply, assign(socket, circles: circles)}
  end

  #def handle_event("multi_select", %{"date" => date, "meal" => meal}, socket) do
    #tps =
      #Enum.map(socket.assigns.templates, fn x ->
        #if x.day == String.to_integer(date) do
          #Map.put(x, :multi_select, meal)
        #else
          #x
        #end
      #end)

    #{:noreply, assign(socket, templates: tps)}
  #end

  #def handle_event("multi_select", _data, socket) do
    ## multi_select clicked twice
    #GroupServer.templates_of_user(socket.assigns.pid, socket.assigns.uid)

    #{:noreply, socket}
  #end

  #def handle_info(%{topic: topic, payload: state}, socket) do
    #if topic == Comiditas.templates_user_topic(socket.assigns.uid) do
      #{:noreply, assign(socket, templates: state.templates)}
    #else
      #{:noreply, socket}
    #end
  #end
end
