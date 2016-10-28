defmodule Comiditas.TemplateTest do
  use Comiditas.ModelCase

  alias Comiditas.Template

  @valid_attrs %{breakfast: "some content", day: 42, dinner: "some content", lunch: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Template.changeset(%Template{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Template.changeset(%Template{}, @invalid_attrs)
    refute changeset.valid?
  end
end
