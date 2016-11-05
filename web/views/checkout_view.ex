defmodule Comiditas.CheckoutView do
  use Comiditas.Web, :view
  use JaSerializer.PhoenixView


  attributes [:date, :breakfast, :lunch, :dinner]

  def id(checkout, _conn), do: checkout.date
end
