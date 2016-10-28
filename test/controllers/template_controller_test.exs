defmodule Comiditas.TemplateControllerTest do
  use Comiditas.ConnCase

  alias Comiditas.Template
  @valid_attrs %{breakfast: "some content", day: 42, dinner: "some content", lunch: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, template_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing templates"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, template_path(conn, :new)
    assert html_response(conn, 200) =~ "New template"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), template: @valid_attrs
    assert redirected_to(conn) == template_path(conn, :index)
    assert Repo.get_by(Template, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, template_path(conn, :create), template: @invalid_attrs
    assert html_response(conn, 200) =~ "New template"
  end

  test "shows chosen resource", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = get conn, template_path(conn, :show, template)
    assert html_response(conn, 200) =~ "Show template"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, template_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = get conn, template_path(conn, :edit, template)
    assert html_response(conn, 200) =~ "Edit template"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = put conn, template_path(conn, :update, template), template: @valid_attrs
    assert redirected_to(conn) == template_path(conn, :show, template)
    assert Repo.get_by(Template, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = put conn, template_path(conn, :update, template), template: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit template"
  end

  test "deletes chosen resource", %{conn: conn} do
    template = Repo.insert! %Template{}
    conn = delete conn, template_path(conn, :delete, template)
    assert redirected_to(conn) == template_path(conn, :index)
    refute Repo.get(Template, template.id)
  end
end
