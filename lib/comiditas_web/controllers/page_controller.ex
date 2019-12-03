defmodule ComiditasWeb.PageController do
  use ComiditasWeb, :controller
  alias Phoenix.LiveView

  # def index(conn, _params) do
  #   render(conn, "index.html")
  # end

  def index(conn, _) do
    LiveView.Controller.live_render(conn, ComiditasWeb.Live.ListView, session: %{})
  end
end
