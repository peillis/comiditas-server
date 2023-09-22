defmodule Mix.Tasks.Comiditas.Purge do
  use Mix.Task

  import Ecto.Query
  alias Comiditas.Accounts.UserToken
  alias Comiditas.{Frozen, Mealdate}
  alias Comiditas.Repo

  @shortdoc "Purge mealdate table of old data."
  def run(_) do
    date = Timex.today() |> Timex.shift(months: -1)
    date_time = DateTime.now!("Etc/UTC") |> DateTime.add(-60*60*24*30, :second)

    Ecto.Migrator.with_repo(Repo, fn repo ->
      repo.delete_all(from m in Mealdate, where: m.date < ^date)
      repo.delete_all(from f in Frozen, where: f.date < ^date)
      repo.delete_all(from u in UserToken, where: u.inserted_at < ^date_time)
    end)
  end
end
