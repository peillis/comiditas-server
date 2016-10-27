defmodule Comiditas.PageController do
  use Comiditas.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
