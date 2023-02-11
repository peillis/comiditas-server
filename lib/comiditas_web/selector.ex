defmodule ComiditasWeb.Selector do
  defstruct show: false, top: 0, left: 0

  defmacro __using__(_) do
    quote do
      use Phoenix.LiveView
      alias ComiditasWeb.Selector
      alias Comiditas.GroupServer
      alias Comiditas.Selection

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

      def handle_event("multi_select", _, socket) do
        socket =
          socket
          |> assign(multi_select_from: socket.assigns.selected)
          |> assign(selector: %Selector{})

        {:noreply, socket}
      end

      def handle_event("change", %{"val" => value}, socket) do
        %{pid: pid, uid: uid, selected: selected, multi_select_from: msf} = socket.assigns
        range =
          if is_nil(msf) do
            {selected, selected}
          else
            {msf, selected}
          end

        case Map.get(socket.assigns, :list) do
          nil -> GroupServer.change_templates(pid, uid, range, value)
          list -> GroupServer.change_days(pid, uid, list, range, value)
        end

        socket =
          socket
          |> assign(multi_select_from: nil)
          |> assign(selector: %Selector{})

        {:noreply, socket}
      end

      defp selector_initial_assign(socket) do
        assign(socket, selected: nil, multi_select_from: nil, selector: %Selector{})
      end

      defp blink(range, r) do
        if Selection.in_range?(range, r) do
          "blink"
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
  end
end
