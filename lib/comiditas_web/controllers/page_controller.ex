defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller
  import Phoenix.LiveView.Controller

  alias Comiditas.Admin

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def list(conn, %{"uid" => uid}) do
    user = Guardian.Plug.current_resource(conn)
    uid = String.to_integer(uid)
    live_render(conn, ComiditasWeb.Live.ListView, session: %{user: user, uid: uid})
  end

  def settings(conn, %{"uid" => uid}) do
    user = Guardian.Plug.current_resource(conn)
    uid = String.to_integer(uid)
    live_render(conn, ComiditasWeb.Live.SettingsView, session: %{user: user, uid: uid})
  end

  def totals(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    live_render(conn, ComiditasWeb.Live.TotalsView, session: %{user: user})
  end

  def users(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    conn = assign(conn, :users, Comiditas.get_users(user.group_id))
    render(conn, "users.html")
  end

  def edit(conn, %{"uid" => uid}) do
    user = Admin.get_user!(uid)
    changeset = Admin.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"uid" => uid, "user" => user_params}) do
    user = Admin.get_user!(uid)
    power_user = Guardian.Plug.current_resource(conn)

    case Admin.update_user(user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.page_path(conn, :users, uid: power_user.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end
end
