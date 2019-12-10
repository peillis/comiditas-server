defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    my_list = ["hey", "there", "you", "go"]
    {:ok, assign(socket, deploy_step: "Ready!", my_list: my_list)}
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end

end
