defmodule Comiditas.MealdateController do
  use Comiditas.Web, :controller
  use Timex

  alias Comiditas.Mealdate
  alias Comiditas.Template

  require Logger
  require IEx

  def index(conn, params) do
    mealdates = Repo.all(Mealdate)
    case get_format(conn) do
      "html" ->
        render(conn, "index.html", mealdates: mealdates)
      "json-api" ->
        user = Guardian.Plug.current_resource(conn)
        page = String.to_integer(params["page"]) || 1
        per_page = String.to_integer(params["per_page"]) || 10
        from = ((page - 1) * per_page) + 1
        to = page * per_page
        mealdates = Enum.map(from..to, fn(x) ->
          date = Timex.shift(Timex.today, days: x-1)
          date_str = Timex.format!(date, "%F", :strftime)
          Mealdate.get_or_template(date_str, user)
        end)
        conn
        |> render %{
          :data => mealdates,
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
    case get_format(conn) do
      "html" ->
        mealdate = Repo.get!(Mealdate, id)
        render(conn, "show.html", mealdate: mealdate)
      "json-api" ->
        user = Guardian.Plug.current_resource(conn)
        mealdate = Mealdate.get_or_template(id, user)
        render(conn, :show, data: mealdate)
    end
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

  # update for json
  def update(conn, %{"id" => id, "data" => data}) do
    attrs = JaSerializer.Params.to_attributes(data)
    user = Guardian.Plug.current_resource(conn)
    mealdate = Mealdate.get_or_template(id, user)
    changeset = Mealdate.changeset(mealdate, attrs)

    result = case mealdate.id do
      nil ->
        Repo.insert(changeset)
      _->
        case Repo.update(changeset) do
          {:ok, mealdate} ->
            # now check if it's the same as the template
            template = Template.get(id, user)
            if is_nil(mealdate.notes)
                and template.breakfast == mealdate.breakfast
                and template.lunch == mealdate.lunch
                and template.dinner == mealdate.dinner do
              Repo.delete!(mealdate)
            end
            {:ok, mealdate}
          {:error, changeset} -> {:error, changeset}
        end
    end

    case result do
      {:ok, mealdate} ->
        conn
        |> put_status(201)
        |> render(:show, data: mealdate)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render(:errors, data: changeset)
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
