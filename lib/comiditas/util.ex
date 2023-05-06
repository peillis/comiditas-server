defmodule Comiditas.Util do
  alias Comiditas.GroupServer

  def str_to_date(str) do
    str
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
    |> Timex.to_date()
  end

  def get_pid(group_id) do
    case GroupServer.start_link(group_id) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  def replace_in_list(elem, list, key) do
    new_list = Enum.filter(list, &(Map.get(&1, key) != Map.get(elem, key)))
    [elem | new_list]
  end
end
