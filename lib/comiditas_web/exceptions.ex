defmodule ComiditasWeb.ForbiddenError do
  defexception message: "forbidden", plug_status: 403
end
