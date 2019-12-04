defmodule Comiditas do
  @moduledoc """
  Comiditas keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query

  alias Comiditas.Mealdate
  alias Comiditas.Repo
  alias Comiditas.Template

  def get_mealdates(_user_id) do
    today = Timex.today()
    # Repo.all(from m in Mealdate, where: m.date >= ^today and m.user_id==5)
    Mealdate
    |> where([m], m.date >= ^today)
    |> where(user_id: 5)
    |> Repo.all
  end

  def get_template(_user_id) do
    Template
    |> where(user_id: 5)
    |> Repo.all
  end

end
