defmodule ComiditasWeb.PowerUserPlug do
  import Plug.Conn

  alias Comiditas.{GroupServer, Util}

  def init(options) do
    options
  end

  def call(%Plug.Conn{params: %{"uid" => uid}} = conn, _opts) do
    user = Guardian.Plug.current_resource(conn)
    if allowed?(user, String.to_integer(uid)) do
      assign(conn, :power_user, user.power_user)
    else
      raise ComiditasWeb.ForbiddenError
    end
  end

  def allowed?(user, uid) do
    pid = Util.get_pid(user.group_id)
    uids = GroupServer.get_uids(pid)

    if (user.id == uid) or (user.power_user and uid in uids) do
      true
    else
      false
    end
  end
end
