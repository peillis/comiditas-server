defmodule ComiditasWeb.Live.SettingsView do
  use ComiditasWeb.Selector

  alias Comiditas.{Accounts, GroupServer, Selection, Util}
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

    socket = selector_initial_assign(socket)

    {:ok, assign(socket, pid: pid, uid: user.id, circles: circles)}
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

  def handle_info(%{topic: topic, payload: state}, socket) do
    if topic == Comiditas.templates_user_topic(socket.assigns.uid) do
      {:noreply, assign(socket, circles: build_circles(state.templates))}
    else
      {:noreply, socket}
    end
  end
end
