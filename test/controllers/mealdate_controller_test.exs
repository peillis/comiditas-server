defmodule Comiditas.MealdateControllerTest do
  use Comiditas.ConnCase

  alias Comiditas.Mealdate
  @valid_attrs %{breakfast: "some content", date: %{day: 17, month: 4, year: 2010}, dinner: "some content", lunch: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, mealdate_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing mealdates"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, mealdate_path(conn, :new)
    assert html_response(conn, 200) =~ "New mealdate"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, mealdate_path(conn, :create), mealdate: @valid_attrs
    assert redirected_to(conn) == mealdate_path(conn, :index)
    assert Repo.get_by(Mealdate, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, mealdate_path(conn, :create), mealdate: @invalid_attrs
    assert html_response(conn, 200) =~ "New mealdate"
  end

  test "shows chosen resource", %{conn: conn} do
    mealdate = Repo.insert! %Mealdate{}
    conn = get conn, mealdate_path(conn, :show, mealdate)
    assert html_response(conn, 200) =~ "Show mealdate"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, mealdate_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    mealdate = Repo.insert! %Mealdate{}
    conn = get conn, mealdate_path(conn, :edit, mealdate)
    assert html_response(conn, 200) =~ "Edit mealdate"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    mealdate = Repo.insert! %Mealdate{}
    conn = put conn, mealdate_path(conn, :update, mealdate), mealdate: @valid_attrs
    assert redirected_to(conn) == mealdate_path(conn, :show, mealdate)
    assert Repo.get_by(Mealdate, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    mealdate = Repo.insert! %Mealdate{}
    conn = put conn, mealdate_path(conn, :update, mealdate), mealdate: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit mealdate"
  end

  test "deletes chosen resource", %{conn: conn} do
    mealdate = Repo.insert! %Mealdate{}
    conn = delete conn, mealdate_path(conn, :delete, mealdate)
    assert redirected_to(conn) == mealdate_path(conn, :index)
    refute Repo.get(Mealdate, mealdate.id)
  end
end
