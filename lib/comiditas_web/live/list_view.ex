defmodule ComiditasWeb.Live.ListView do
  use Phoenix.LiveView

  alias Comiditas.Util

  def render(assigns) do
    ComiditasWeb.PageView.render("list.html", assigns)
  end

  def mount(_session, socket) do
    user_id = 5
    mealdates = Comiditas.get_mealdates(user_id)
    templates = Comiditas.get_templates(user_id)
    list = Comiditas.generate_days(10, mealdates, templates)

    {:ok,
     assign(socket, deploy_step: "Ready!", user_id: user_id, list: list, mealdates: mealdates, templates: templates)}
  end

  def refresh(socket) do
    user_id = 5
    mealdates = Comiditas.get_mealdates(user_id)
    templates = Comiditas.get_templates(user_id)
    list = Comiditas.generate_days(10, mealdates, templates)
    socket
    |> assign(user_id: user_id, list: list)
    |> assign(mealdates: mealdates, templates: templates)
  end

  def handle_event("github_deploy", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Starting deploy...")}
  end

  def handle_event("my_test", _value, socket) do
    {:noreply, assign(socket, deploy_step: "Hey test")}
  end

  def handle_event("view_more", _value, socket) do
    len = length(socket.assigns.list) + 10

    list =
      if len < 300 do
        Comiditas.generate_days(len, socket.assigns.mealdates, socket.assigns.templates)
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
          _ -> %{x | selected: nil}
        end
      end)

    # require IEx; IEx.pry
    {:noreply, assign(socket, list: new_list)}
  end

  def handle_event("multi_select", _value, socket) do
    IO.inspect("multi select")
    {:noreply, socket}
  end

  def handle_event("change", %{"date" => date, "meal" => meal, "val" => val}, socket) do
    IO.inspect("#{date} #{meal} #{val}")
    user_id = socket.assigns.user_id
    date = Util.str_to_date(date)
    templates = socket.assigns.templates
    Comiditas.change_day(user_id, date, meal, val, templates)

    {:noreply, socket}
  end

end
