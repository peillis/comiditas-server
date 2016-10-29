defmodule Comiditas.Auth do
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def login_by_email_and_pass(conn, email, given_pass) do
    user = Comiditas.Repo.get_by(Comiditas.User, email: email)
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, user, conn}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end
end
