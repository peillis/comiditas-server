defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller

  alias Comiditas.GroupServer
  alias Comiditas.Users
  alias Comiditas.Util
  alias Comiditas.Accounts.User

  def index(conn, _params) do
    case conn.assigns.current_user do
      nil -> redirect(conn, to: "/users/log_in")
      _ -> redirect(conn, to: "/app/list")
    end
  end

  def users(conn, _) do
    user = conn.assigns.current_user

    conn =
      conn
      |> assign(:users, Comiditas.get_users(user.group_id))
      |> delete_session(:uid)

    render(conn, "users.html")
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    # Add the group_id to the user
    power_user = conn.assigns.current_user
    user_params = Map.put(user_params, "group_id", power_user.group_id)

    case Users.create_user(user_params) do
      {:ok, _user} ->
        pid = Util.get_pid(power_user.group_id)
        GroupServer.refresh(pid)

        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"uid" => uid}) do
    user = Users.get_user!(uid)
    power_user = conn.assigns.current_user

    if power_user.group_id == user.group_id do
      changeset = Users.change_user(user)
      render(conn, "edit.html", user: user, changeset: changeset)
    else
      conn
      |> put_status(404)
      |> render(ComiditasWeb.ErrorView, "404.html")
      |> halt()
    end
  end

  def update(conn, %{"uid" => uid, "user" => user_params}) do
    user = Users.get_user!(uid)
    power_user = conn.assigns.current_user

    if power_user.group_id == user.group_id do
      case Users.update_user(user, user_params) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "User updated successfully.")
          |> redirect(to: Routes.page_path(conn, :users))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", user: user, changeset: changeset)
      end
    else
      conn
      |> put_status(404)
      |> render(ComiditasWeb.ErrorView, "404.html")
      |> halt()
    end
  end

  def delete(conn, %{"uid" => uid}) do
    user = Users.get_user!(uid)
    power_user = conn.assigns.current_user

    if power_user.group_id == user.group_id do
      {:ok, _user} = Users.delete_user(user)
      pid = Util.get_pid(power_user.group_id)
      GroupServer.refresh(pid)

      conn
      |> put_flash(:info, "User deleted successfully.")
      |> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))
    else
      conn
      |> put_status(404)
      |> render(ComiditasWeb.ErrorView, "404.html")
      |> halt()
    end
  end

  def impersonate(conn, %{"uid" => uid}) do
    conn
    |> put_session(:uid, uid)
    |> redirect(to: Routes.live_path(conn, ComiditasWeb.Live.ListView))
  end
end
