defmodule Comiditas.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :comiditas

  import Ecto.Query
  alias Comiditas.Accounts.UserToken
  alias Comiditas.{Frozen, Mealdate}
  alias Comiditas.Repo

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def purge do
    load_app()

    date = Timex.today() |> Timex.shift(months: -1)
    date_time = DateTime.now!("Etc/UTC") |> DateTime.add(-60*60*24*30, :second)

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn repo ->
        repo.delete_all(from m in Mealdate, where: m.date < ^date)
        repo.delete_all(from f in Frozen, where: f.date < ^date)
        repo.delete_all(from u in UserToken, where: u.inserted_at < ^date_time)
      end)
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
