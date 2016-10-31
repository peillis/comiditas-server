defmodule Comiditas.CORS do
  use Corsica.Router,
    origins: "*",
    allow_credentials: true,
    allow_headers: ~w(authorization)

  resource "/api/*"
  resource "/*"
end
