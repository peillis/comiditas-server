defmodule Comiditas.GroupServer do
  use GenServer

  alias Comiditas.{Totals, Util}
  alias ComiditasWeb.Endpoint

  def start_link(group_id) do
    GenServer.start_link(__MODULE__, group_id, name: {:global, "GroupServer_#{group_id}"})
  end

  def refresh(pid) do
    GenServer.cast(pid, :refresh)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def gen_days_of_user(pid, n, user_id, list \\ []) do
    GenServer.call(pid, {:gen_days_of_user, n, user_id, list})
  end

  def change_day(pid, changeset) do
    GenServer.call(pid, {:change_day, changeset})
    totals(pid, changeset.data.date)
    # in case it's breakfast
    totals(pid, Timex.shift(changeset.data.date, days: -1))
  end

  def change_days(pid, uid, list, date_from, meal_from, date_to, meal_to, value) do
    GenServer.call(pid, {:change_days, uid, list, date_from, meal_from, date_to, meal_to, value})
    gen_days_of_user(pid, length(list), uid)
    ndays = Timex.diff(date_to, date_from, :days)

    for d <- -1..ndays do
      totals(pid, Timex.shift(date_from, days: d))
    end
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
    GenServer.call(pid, {:totals, date})
  end

  def get_uids(pid) do
    GenServer.call(pid, :get_uids)
  end

  @impl true
  def init(group_id) do
    state =
      group_id
      |> get_data()
      |> Map.put(:start, Timex.now())
      |> Map.put(:last_op, Timex.now())

    check_time_running()

    {:ok, state}
  end

  @impl true
  def handle_cast(:refresh, state) do
    state =
      state.group_id
      |> get_data()
      |> update_timestamp()

    {:noreply, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:get_uids, _from, state) do
    user_ids = Enum.map(state.users, & &1.id)
    {:reply, user_ids, update_timestamp(state)}
  end

  @impl true
  def handle_call({:change_day, changeset}, _from, state) do
    user = find_user(state.users, changeset.data.user_id)
    tpl = Enum.find(user.tps, &(&1.day == changeset.data.weekday))
    Comiditas.save_day(changeset, tpl)

    state =
      state
      |> refresh_user(user.id, :mds)
      |> update_timestamp()

    {:reply, nil, state}
  end

  @impl true
  def handle_call(
        {:change_days, uid, list, date_from, meal_from, date_to, meal_to, value},
        _from,
        state
      ) do
    user = find_user(state.users, uid)
    Comiditas.change_days(list, user.tps, date_from, meal_from, date_to, meal_to, value)

    state =
      state
      |> refresh_user(uid, :mds)
      |> update_timestamp()

    {:reply, nil, state}
  end

  @impl true
  def handle_call({:templates_of_user, uid}, _from, state) do
    user = find_user(state.users, uid)
    tps = Enum.sort_by(user.tps, & &1.day)
    Endpoint.broadcast(Comiditas.templates_user_topic(uid), "templates", %{templates: tps})

    {:reply, tps, update_timestamp(state)}
  end

  @impl true
  def handle_call({:change_template, changeset}, _from, state) do
    tp = Comiditas.save_template(changeset)

    state =
      state
      |> refresh_user(changeset.data.user_id, :tps)
      |> update_timestamp()

    {:reply, tp, state}
  end

  @impl true
  def handle_call({:totals, date}, _from, state) do
    totals = Totals.get_totals(state.users, date)

    Endpoint.broadcast(
      Comiditas.totals_topic(state.group_id, date),
      "totals",
      totals
    )

    {:reply, totals, update_timestamp(state)}
  end

  @impl true
  def handle_call({:gen_days_of_user, n, user_id, list}, _from, state) do
    user = find_user(state.users, user_id)

    date =
      case Enum.at(list, -1) do
        nil -> Comiditas.today()
        last -> Timex.shift(last.date, days: 1)
      end

    new_list = list ++ Comiditas.generate_days(n, user.mds, user.tps, date)
    Endpoint.broadcast(Comiditas.user_topic(user_id), "list", %{list: new_list})

    {:reply, new_list, update_timestamp(state)}
  end

  @impl true
  def handle_info(:suicide, state) do
    # stops genserver if not accessed in the last hour
    diff = Timex.diff(Timex.now(), state.last_op, :minutes)

    case diff do
      x when x > 60 ->
        {:stop, :normal, state}

      _ ->
        check_time_running()
        {:noreply, state}
    end
  end

  defp find_user(users, user_id) do
    Enum.find(users, &(&1.id == user_id))
  end

  defp refresh_user(state, uid, key) do
    user = find_user(state.users, uid)

    mod_user =
      case key do
        :mds -> %{user | mds: Comiditas.get_mealdates_of_users([uid])}
        :tps -> %{user | tps: Comiditas.get_templates_of_users([uid])}
      end

    mod_users = Util.replace_in_list(mod_user, state.users, :id)

    %{state | users: mod_users}
  end

  defp get_data(group_id) do
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

    %{users: users, group_id: group_id}
  end

  defp update_timestamp(state) do
    %{state | last_op: Timex.now()}
  end

  defp check_time_running do
    # check every 15 minutes
    Process.send_after(self(), :suicide, 15 * 60 * 1000)
  end
end
