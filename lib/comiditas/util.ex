defmodule Comiditas.Util do
  def str_to_date(str) do
    str
    |> Timex.parse!("{YYYY}-{0M}-{0D}")
    |> Timex.to_date()
  end
end
