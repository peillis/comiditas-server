defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    user_id = 5
    mealdates = Comiditas.get_mealdates(user_id)
    templates = Comiditas.get_templates(user_id)
    list = Comiditas.generate_dates(10, mealdates, templates)

    {:ok, assign(socket, deploy_step: "Ready!", list: list, mealdates: mealdates, templates: templates)}
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + 10
    list = if len < 300 do
      Comiditas.generate_dates(len, socket.assigns.mealdates, socket.assigns.templates)
    else
      socket.assigns.list
    end

    {:noreply, assign(socket, list: list)}
  end

  def handle_event("select", %{"date" => date, "meal" => meal}, socket) do
    IO.inspect(date)
    IO.inspect(meal)
    list = socket.assigns.list
    d =
      date
      |> Timex.parse!("{YYYY}-{0M}-{0D}")
      |> Timex.to_date()
    new_list =
      Enum.map(list, fn x ->
        case x.date do
          ^d -> %{x | selected: meal}
          _ -> %{x | selected: 0}
        end
      end)
    # require IEx; IEx.pry
    {:noreply, assign(socket, list: new_list)}
  end
end
