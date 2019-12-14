defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView
  alias Comiditas.UserServer

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    {:ok, pid} = UserServer.start_link(5)
    list = UserServer.get_list(pid)

    {:ok, assign(socket, deploy_step: "Ready!", list: list, pid: pid)}
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end
end
