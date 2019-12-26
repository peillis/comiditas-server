defmodule Comiditas.GroupServer do
  use GenServer

  alias Comiditas.{Mealdate, Totals}
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
    gen_days_of_user(pid, length(list), day.user_id)
    totals(pid, date)
    totals(pid, Timex.shift(date, days: -1))
  end

  def totals(pid, date) do
    GenServer.cast(pid, {:totals, date})
  end

  @impl true
  def init(group_id) do
    users =
      group_id
      |> Comiditas.get_users()
      |> Enum.map(&Map.take(&1, [:id, :name]))

    user_ids = Enum.map(users, & &1.id)
    mealdates = Comiditas.get_mealdates_of_users(user_ids)
    templates = Comiditas.get_templates_of_users(user_ids)

    users =
      users
      |> Enum.map(&(Map.merge(&1, %{mds: Comiditas.filter(mealdates, &1.id)})))
      |> Enum.map(&(Map.merge(&1, %{tps: Comiditas.filter(templates, &1.id)})))

    {:ok, %{mds: mealdates, tps: templates, users: users, group_id: group_id}}
  end

  @impl true
  def handle_call(:get_list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:gen_days_of_user, n, user_id}, state) do
    user = find_user(state.users, user_id)
    list = Comiditas.generate_days(n, user.mds, user.tps)
    Endpoint.broadcast(Comiditas.user_topic(user_id), "list", %{list: list})
    {:noreply, state}
  end

  @impl true
  def handle_call({:change_day, day, date, meal, value}, _from, state) do
    changeset = Mealdate.changeset(day, Map.put(%{}, meal, value))
    user = find_user(state.users, day.user_id)
    tpl = Enum.find(user.tps, &(&1.day == day.weekday))

    mds =
      case Comiditas.save_day(changeset, tpl) do
        {:deleted, day} ->
          Enum.filter(user.mds, &(!(&1.date == date)))

        {:updated, day} ->
          replace_in_list(user.mds, day)

        {:created, day} ->
          [day | user.mds]
      end

    new_user = %{user | mds: mds}
    users =
      state.users
      |> Enum.filter(&(&1.id != day.user_id))

    {:reply, day, %{state | users: [new_user | users]}}
  end

  @impl true
  def handle_cast({:totals, date}, state) do
    totals = Totals.get_totals(state.users, date)

    Endpoint.broadcast(
      Comiditas.totals_topic(state.group_id, date),
      "totals",
      totals
    )

    {:noreply, state}
  end

  def find_user(users, user_id) do
    Enum.find(users, &(&1.id == user_id))
  end

  defp replace_in_list(list, elem) do
    Enum.map(list, fn x ->
      if x.date == elem.date do
        elem
      else
        x
      end
    end)
  end
end
