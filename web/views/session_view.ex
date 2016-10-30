defmodule Comiditas.SessionView do
  use Comiditas.Web, :view

  def render("error.json", %{:message => message}) do
    %{error: message}
  end

  def render("login.json", %{:jwt => jwt, :exp => exp}) do
    %{jwt: jwt, exp: exp}
  end

end
