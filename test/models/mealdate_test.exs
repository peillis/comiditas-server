defmodule Comiditas.MealdateTest do
  use Comiditas.ModelCase

  alias Comiditas.Mealdate

  @valid_attrs %{breakfast: "some content", date: %{day: 17, month: 4, year: 2010}, dinner: "some content", lunch: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Mealdate.changeset(%Mealdate{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Mealdate.changeset(%Mealdate{}, @invalid_attrs)
    refute changeset.valid?
  end
end
