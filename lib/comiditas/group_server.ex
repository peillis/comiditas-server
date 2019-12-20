defmodule Comiditas.GroupServer do
  use GenServer

  alias Comiditas.Mealdate
  alias ComiditasWeb.Endpoint

  def start_link(group_id) do
    GenServer.start_link(__MODULE__, group_id, name: {:global, "GroupServer_#{group_id}"})
  end

  def get_list(pid) do
    GenServer.call(pid, :get_list)
  end

  def gen_days_of_user(pid, n, user_id) do
    GenServer.cast(pid, {:gen_days_of_user, n, user_id})
  end

  def change_day(pid, list, date, meal, val) do
    day = Enum.find(list, &(&1.date == date))
    GenServer.call(pid, {:change_day, day, date, meal, val})
    GenServer.cast(pid, {:gen_days_of_user, length(list), day.user_id})
  end

  @impl true
  def init(group_id) do
    users = Comiditas.get_users(group_id)
    user_ids = Enum.map(users, & &1.id)
    mealdates = Comiditas.get_mealdates_of_group(user_ids)
    templates = Comiditas.get_templates_of_group(user_ids)

    {:ok, %{mds: mealdates, tps: templates}}
  end

  @impl true
  def handle_call(:get_list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:gen_days_of_user, n, user_id}, state) do
    list = Comiditas.generate_days(n, state.mds, state.tps, user_id)
    Endpoint.broadcast("user:#{user_id}", "list", %{list: list})
    {:noreply, state}
  end

  @impl true
  def handle_call({:change_day, day, date, meal, value}, _from, state) do
    changeset = Mealdate.changeset(day, Map.put(%{}, meal, value))
    tpl = Enum.find(state.tps, &(&1.user_id == day.user_id and &1.day == day.weekday))
    mds =
      case Comiditas.save_day(changeset, tpl) do
        {:deleted, day} -> Enum.filter(state.mds, &(!(&1.date == date and &1.user_id == day.user_id)))
        {:updated, day} -> replace_in_list(state.mds, day)
        {:created, day} -> [day | state.mds]
      end

    {:reply, day, %{state | mds: mds}}
  end

  defp replace_in_list(list, elem) do
    Enum.map(list, fn x ->
      if x.date == elem.date and x.user_id == elem.user_id do
        elem
      else
        x
      end
    end)
  end
end