defmodule Comiditas.TemplateView do
  use Comiditas.Web, :view
  use JaSerializer.PhoenixView

  attributes [:day, :breakfast, :lunch, :dinner]
end
