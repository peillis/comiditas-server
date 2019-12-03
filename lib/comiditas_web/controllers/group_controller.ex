defmodule ComiditasWeb.GroupController do
  use ComiditasWeb, :controller

  alias Comiditas.Comidas
  alias Comiditas.Comidas.Group

  plug(:put_layout, {ComiditasWeb.LayoutView, "torch.html"})

  def index(conn, params) do
    case Comidas.paginate_groups(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Groups. #{inspect(error)}")
        |> redirect(to: Routes.group_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Comidas.change_group(%Group{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"group" => group_params}) do
    case Comidas.create_group(group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group created successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    group = Comidas.get_group!(id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => id}) do
    group = Comidas.get_group!(id)
    changeset = Comidas.change_group(group)
    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def update(conn, %{"id" => id, "group" => group_params}) do
    group = Comidas.get_group!(id)

    case Comidas.update_group(group, group_params) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group updated successfully.")
        |> redirect(to: Routes.group_path(conn, :show, group))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    group = Comidas.get_group!(id)
    {:ok, _group} = Comidas.delete_group(group)

    conn
    |> put_flash(:info, "Group deleted successfully.")
    |> redirect(to: Routes.group_path(conn, :index))
  end
end