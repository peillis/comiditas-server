defmodule ComiditasWeb.RootUserPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)
    if user.root_user do
      conn
    else
      raise ComiditasWeb.ForbiddenError
    end
  end

end
