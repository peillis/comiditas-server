defmodule Comiditas.SessionController do
  use Comiditas.Web, :controller

  alias Comiditas.User
  alias Comiditas.Auth

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case Auth.login_by_email_and_pass(email, password) do
      {:ok, verified_user} ->
        conn
        |> put_flash(:info, "Logged in.")
        |> Guardian.Plug.sign_in(verified_user) # verify your logged in resource
        |> redirect(to: user_path(conn, :index))
      {:error, error} ->
        conn
        |> put_flash(:error, "Invalid credentials")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: session_path(conn, :new))
  end
end
