defmodule Comiditas.GroupServer do
  use GenServer

  alias Comiditas.{Mealdate, Totals, Util}
  alias ComiditasWeb.Endpoint

  def start_link(group_id) do
    GenServer.start_link(__MODULE__, group_id, name: {:global, "GroupServer_#{group_id}"})
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def gen_days_of_user(pid, n, user_id) do
    GenServer.cast(pid, {:gen_days_of_user, n, user_id})
  end

  def change_day(pid, changeset) do
    GenServer.call(pid, {:change_day, changeset})
    totals(pid, changeset.data.date)
    totals(pid, Timex.shift(changeset.data.date, days: -1))  # in case it's breakfast
  end

  def templates_of_user(pid, user_id) do
    GenServer.call(pid, {:templates_of_user, user_id})
  end

  def change_template(pid, changeset) do
    GenServer.call(pid, {:change_template, changeset})
    templates_of_user(pid, changeset.data.user_id)
    gen_days_of_user(pid, 15, changeset.data.user_id)
    totals(pid, Comiditas.today())
  end

  def totals(pid, date) do
    GenServer.cast(pid, {:totals, date})
  end

  def get_uids(pid) do
    GenServer.call(pid, :get_uids)
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
      |> Enum.map(&Map.merge(&1, %{mds: Comiditas.filter(mealdates, &1.id)}))
      |> Enum.map(&Map.merge(&1, %{tps: Comiditas.filter(templates, &1.id)}))

    {:ok, %{users: users, group_id: group_id}}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_uids, _from, state) do
    user_ids = Enum.map(state.users, & &1.id)
    {:reply, user_ids, state}
  end

  @impl true
  def handle_call({:change_day, changeset}, _from, state) do
    user = find_user(state.users, changeset.data.user_id)
    tpl = Enum.find(user.tps, &(&1.day == changeset.data.weekday))

    mds =
      case Comiditas.save_day(changeset, tpl) do
        {:deleted, _day} ->
          Enum.filter(user.mds, &(!(&1.date == changeset.data.date)))

        {:updated, day} ->
          Util.replace_in_list(day, user.mds, :date)

        {:created, day} ->
          [day | user.mds]
      end

    new_user = %{user | mds: mds}
    new_user_list = Util.replace_in_list(new_user, state.users, :id)

    {:reply, changeset, %{state | users: new_user_list}}
  end

  @impl true
  def handle_call({:templates_of_user, uid}, _from, state) do
    user = find_user(state.users, uid)
    tps = Enum.sort_by(user.tps, & &1.day)
    Endpoint.broadcast(Comiditas.templates_user_topic(uid), "templates", %{templates: tps})
    {:reply, tps, state}
  end

  @impl true
  def handle_call({:change_template, changeset}, _from, state) do
    tp = Comiditas.save_template(changeset)
    user = find_user(state.users, changeset.data.user_id)
    tps = Util.replace_in_list(tp, user.tps, :day)
    new_user = %{user | tps: tps}
    new_user_list = Util.replace_in_list(new_user, state.users, :id)

    {:reply, tp, %{state | users: new_user_list}}
  end

  @impl true
  def handle_cast({:gen_days_of_user, n, user_id}, state) do
    user = find_user(state.users, user_id)
    list = Comiditas.generate_days(n, user.mds, user.tps)
    Endpoint.broadcast(Comiditas.user_topic(user_id), "list", %{list: list})
    {:noreply, state}
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

end
