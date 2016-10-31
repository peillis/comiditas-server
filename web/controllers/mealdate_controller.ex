defmodule Comiditas.MealdateController do
  use Comiditas.Web, :controller

  alias Comiditas.Mealdate

  require Logger
  require IEx

  def index(conn, _params) do
    mealdates = Repo.all(Mealdate)
    case get_format(conn) do
      "html" ->
        render(conn, "index.html", mealdates: mealdates)
      _ ->
        user = Guardian.Plug.current_resource(conn)
        conn
        |> render %{
          :data => Repo.all(Mealdate),
          :opts => [{:meta, %{:total_pages => 10}}]
        }
    end
  end

  def new(conn, _params) do
    changeset = Mealdate.changeset(%Mealdate{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mealdate" => mealdate_params}) do
    changeset = Mealdate.changeset(%Mealdate{}, mealdate_params)

    case Repo.insert(changeset) do
      {:ok, _mealdate} ->
        conn
        |> put_flash(:info, "Mealdate created successfully.")
        |> redirect(to: mealdate_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mealdate = Repo.get!(Mealdate, id)
    render(conn, "show.html", mealdate: mealdate)
  end

  def edit(conn, %{"id" => id}) do
    mealdate = Repo.get!(Mealdate, id)
    changeset = Mealdate.changeset(mealdate)
    render(conn, "edit.html", mealdate: mealdate, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mealdate" => mealdate_params}) do
    mealdate = Repo.get!(Mealdate, id)
    changeset = Mealdate.changeset(mealdate, mealdate_params)

    case Repo.update(changeset) do
      {:ok, mealdate} ->
        conn
        |> put_flash(:info, "Mealdate updated successfully.")
        |> redirect(to: mealdate_path(conn, :show, mealdate))
      {:error, changeset} ->
        render(conn, "edit.html", mealdate: mealdate, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mealdate = Repo.get!(Mealdate, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(mealdate)

    conn
    |> put_flash(:info, "Mealdate deleted successfully.")
    |> redirect(to: mealdate_path(conn, :index))
  end
end
