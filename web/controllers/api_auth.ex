defmodule Comiditas.ApiAuth do
  use Comiditas.Web, :controller

  def unauthenticated(conn, params) do
    conn
    |> put_status(401)
    |> put_view(Comiditas.SessionView)
    |> render "error.json", message: "Authentication required"
  end

end
