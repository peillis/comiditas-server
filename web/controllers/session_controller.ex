defmodule Comiditas.SessionController do
  use Comiditas.Web, :controller

  alias Comiditas.User
  alias Comiditas.Auth

  require IEx

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{"user" => %{"email" => email, "password" => password}}) do
    case get_format(conn) do
      "html" ->
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
      _ ->
        case Auth.login_by_email_and_pass(email, password) do
          {:ok, verified_user} ->
            new_conn = Guardian.Plug.api_sign_in(conn, verified_user)
            jwt = Guardian.Plug.current_token(new_conn)
            {:ok, claims} = Guardian.Plug.claims(new_conn)
            exp = Map.get(claims, "exp")

            new_conn
            |> put_resp_header("x-expires", to_string(exp))
            |> put_resp_header("authorization", "Bearer #{jwt}")
            |> render "login.json", jwt: jwt, exp: exp
          {:error, error} ->
            conn
            |> put_status(401)
            |> render "error.json", message: "Could not login"
        end
    end

  end

  def delete(conn, _) do
    Guardian.Plug.sign_out(conn)
    |> put_flash(:info, "Logged out successfully.")
    |> redirect(to: session_path(conn, :new))
  end
end
