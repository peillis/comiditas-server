defmodule Comiditas.CORS do
  use Corsica.Router,
    origins: "*",
    allow_credentials: true,
    allow_headers: ~w(authorization accept origin)

  resource "/api/*"
  resource "/*"
end