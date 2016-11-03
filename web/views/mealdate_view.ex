defmodule Comiditas.MealdateView do
  use Comiditas.Web, :view
  use JaSerializer.PhoenixView

  attributes [:date, :breakfast, :lunch, :dinner]

  def id(mealdate, _conn), do: mealdate.date
end
