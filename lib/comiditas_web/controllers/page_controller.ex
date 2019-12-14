defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller
  import Phoenix.LiveView.Controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  # def index(conn, _) do
  #   live_render(conn, ComiditasWeb.Live.ListView, session: %{})
  # end
end
