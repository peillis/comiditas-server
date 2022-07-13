defmodule ComiditasWeb.UserControllerTest do
  use ComiditasWeb.ConnCase

  setup :register_and_log_in_root_user

  @create_attrs %{
    email: "some@email",
    name: "some name",
    password: "some password",
    power_user: false,
    root_user: false
  }
  @update_attrs %{
    email: "some@updated_email",
    name: "some updated name",
    password: "some updated password",
    power_user: false,
    root_user: false
  }
  @invalid_attrs %{
    email: nil,
    group_id: nil,
    name: nil,
    password: nil,
    power_user: nil,
    root_user: nil
  }

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Users"
    end
  end

  describe "new user" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :new))
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      group = Comiditas.GroupsFixtures.group_fixture()
      attrs = Map.put(@create_attrs, :group_id, group.id)
      conn = post conn, Routes.user_path(conn, :create), user: attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "User Details"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, Routes.user_path(conn, :create), user: @invalid_attrs
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :edit, user))
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put conn, Routes.user_path(conn, :update, user), user: @update_attrs
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some@updated_email"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, Routes.user_path(conn, :update, user), user: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = Comiditas.UsersFixtures.user_fixture(@create_attrs)
    {:ok, user: user}
  end
end
