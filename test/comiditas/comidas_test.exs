defmodule Comiditas.ComidasTest do
  use Comiditas.DataCase

  alias Comiditas.Comidas

  describe "groups" do
    alias Comiditas.Comidas.Group

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def group_fixture(attrs \\ %{}) do
      {:ok, group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Comidas.create_group()

      group
    end

    test "paginate_groups/1 returns paginated list of groups" do
      for _ <- 1..20 do
        group_fixture()
      end

      {:ok, %{groups: groups} = page} = Comidas.paginate_groups(%{})

      assert length(groups) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_groups/0 returns all groups" do
      group = group_fixture()
      assert Comidas.list_groups() == [group]
    end

    test "get_group!/1 returns the group with given id" do
      group = group_fixture()
      assert Comidas.get_group!(group.id) == group
    end

    test "create_group/1 with valid data creates a group" do
      assert {:ok, %Group{} = group} = Comidas.create_group(@valid_attrs)
      assert group.name == "some name"
    end

    test "create_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Comidas.create_group(@invalid_attrs)
    end

    test "update_group/2 with valid data updates the group" do
      group = group_fixture()
      assert {:ok, group} = Comidas.update_group(group, @update_attrs)
      assert %Group{} = group
      assert group.name == "some updated name"
    end

    test "update_group/2 with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Comidas.update_group(group, @invalid_attrs)
      assert group == Comidas.get_group!(group.id)
    end

    test "delete_group/1 deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Comidas.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Comidas.get_group!(group.id) end
    end

    test "change_group/1 returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Comidas.change_group(group)
    end
  end

  describe "users" do
    alias Comiditas.Comidas.User

    @valid_attrs %{
      email: "some email",
      group_id: 42,
      name: "some name",
      password_hash: "some password_hash"
    }
    @update_attrs %{
      email: "some updated email",
      group_id: 43,
      name: "some updated name",
      password_hash: "some updated password_hash"
    }
    @invalid_attrs %{email: nil, group_id: nil, name: nil, password_hash: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Comidas.create_user()

      user
    end

    test "paginate_users/1 returns paginated list of users" do
      for _ <- 1..20 do
        user_fixture()
      end

      {:ok, %{users: users} = page} = Comidas.paginate_users(%{})

      assert length(users) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Comidas.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Comidas.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Comidas.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.group_id == 42
      assert user.name == "some name"
      assert user.password_hash == "some password_hash"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Comidas.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Comidas.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.group_id == 43
      assert user.name == "some updated name"
      assert user.password_hash == "some updated password_hash"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Comidas.update_user(user, @invalid_attrs)
      assert user == Comidas.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Comidas.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Comidas.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Comidas.change_user(user)
    end
  end
end
