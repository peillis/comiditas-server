defmodule ComiditasWeb.LayoutView do
  use ComiditasWeb, :view

  def menu_class(conn) do
    uid = String.to_integer(conn.params["uid"])
    user = Guardian.Plug.current_resource(conn)

    if uid == user.id or conn.private.phoenix_template == "edit.html" do
      ""
    else
      "red"
    end
  end
end
