defmodule Comiditas.UserServer do
  use GenServer

  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id)
  end

  def get_list(pid) do
    GenServer.call(pid, :get_list)
  end

  @impl true
  def init(user_id) do
    mealdates = Comiditas.get_mealdates(user_id)
    templates = Comiditas.get_templates(user_id)
    list = Comiditas.generate_days(10, mealdates, templates)
    {:ok, list}
  end

  @impl true
  def handle_call(:get_list, _from, state) do
    {:reply, state, state}
  end
end
