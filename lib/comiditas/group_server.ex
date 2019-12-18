defmodule Comiditas.GroupServer do
  use GenServer

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
    days = Comiditas.generate_days(n, state.mds, state.tps, user_id)
    Endpoint.broadcast("user:#{user_id}", "list", %{list: days})
    {:noreply, state}
  end
end
