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

  #def list(conn, %{"uid" => uid}) do
    #user = conn.assigns.current_user
    #uid = String.to_integer(uid)
    #live_render(conn, ComiditasWeb.Live.ListView, session: %{user: user, uid: uid})
  #end

  #def settings(conn, %{"uid" => uid}) do
    #user = Guardian.Plug.current_resource(conn)
    #uid = String.to_integer(uid)
    #live_render(conn, ComiditasWeb.Live.SettingsView, session: %{user: user, uid: uid})
  #end

  #def totals(conn, _) do
    #user = Guardian.Plug.current_resource(conn)
    #live_render(conn, ComiditasWeb.Live.TotalsView, session: %{user: user})
  #end

  def users(conn, _) do
    user = conn.assigns.current_user
    conn = assign(conn, :users, Comiditas.get_users(user.group_id))
    render(conn, "users.html")
  end

  def new(conn, _params) do
    changeset = Admin.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  #def create(conn, %{"user" => user_params}) do
    ## Add the group_id to the user
    #power_user = Guardian.Plug.current_resource(conn)
    #user_params = Map.put(user_params, "group_id", power_user.group_id)

    #case Admin.create_user(user_params) do
      #{:ok, _user} ->
        #pid = Util.get_pid(power_user.group_id)
        #GroupServer.refresh(pid)

        #conn
        #|> put_flash(:info, "User created successfully.")
        #|> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))

      #{:error, %Ecto.Changeset{} = changeset} ->
        #render(conn, "new.html", changeset: changeset)
    #end
  #end

  def edit(conn, %{"uid" => uid}) do
    user = Users.get_user!(uid)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"uid" => uid, "user" => user_params}) do
    user = Users.get_user!(uid)
    power_user = conn.assigns.current_user

    case Users.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"uid" => uid}) do
    user = Users.get_user!(uid)
    power_user = conn.assigns.current_user
    {:ok, _user} = Users.delete_user(user)
    pid = Util.get_pid(power_user.group_id)
    GroupServer.refresh(pid)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))
  end
end
