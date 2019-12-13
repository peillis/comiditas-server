defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    mds = Comiditas.get_mealdates(5)
    tps = Comiditas.get_templates(5)
    my_list = Comiditas.generate_dates(10, mds, tps)
    {:ok, assign(socket, deploy_step: "Ready!", my_list: my_list)}
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end
end
