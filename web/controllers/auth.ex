defmodule Comiditas.Auth do
  use Comiditas.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def login_by_email_and_pass(email, given_pass) do
    user = Comiditas.Repo.get_by(Comiditas.User, email: email)
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, user}
      user ->
        {:error, :unauthorized}
      true ->
        dummy_checkpw()
        {:error, :not_found}
    end
  end

  def unauthenticated(conn, params) do
    conn
    |> put_status(401)
    |> put_flash(:error, "Authentication required")
    |> redirect(to: session_path(conn, :new))
  end

end
