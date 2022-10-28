defmodule Mix.Tasks.Comiditas.Purge do
  use Mix.Task

  import Ecto.Query
  alias Comiditas.{Frozen, Mealdate}
  alias Comiditas.Repo

  @shortdoc "Purge mealdate table of old data."
  def run(_) do
    date = Timex.today() |> Timex.shift(months: -2)

    Ecto.Migrator.with_repo(Repo, fn repo ->
      repo.delete_all(from m in Mealdate, where: m.date < ^date)
      repo.delete_all(from f in Frozen, where: f.date < ^date)
    end)
  end
end
