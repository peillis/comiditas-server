defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def list(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    live_render(conn, ComiditasWeb.Live.ListView, session: %{user: user})
  end

  def totals(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    live_render(conn, ComiditasWeb.Live.TotalsView, session: %{user: user})
  end
end
