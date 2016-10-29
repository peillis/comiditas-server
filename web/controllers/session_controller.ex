defmodule Comiditas.SessionController do
  use Comiditas.Web, :controller

  alias Comiditas.User
  alias Comiditas.UserQuery

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, params = %{}) do
    conn
    |> put_flash(:info, "Logged in.")
    # |> Guardian.Plug.sign_in(verified_user) # verify your logged in resource
    |> redirect(to: user_path(conn, :index))
  end

  def delete(conn, _params) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: "/")
  end
end
