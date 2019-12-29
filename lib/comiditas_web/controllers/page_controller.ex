defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller
  import Phoenix.LiveView.Controller

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
end
