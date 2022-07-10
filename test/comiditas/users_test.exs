defmodule Comiditas.UsersTest do
  use Comiditas.DataCase

  alias Comiditas.Users

  alias Comiditas.Users.User

  @valid_attrs %{email: "some email", group_id: 42, name: "some name", password: "some password", power_user: true, root_user: true}
  @update_attrs %{email: "some updated email", group_id: 43, name: "some updated name", password: "some updated password", power_user: false, root_user: false}
  @invalid_attrs %{email: nil, group_id: nil, name: nil, password: nil, power_user: nil, root_user: nil}

  describe "#paginate_users/1" do
    test "returns paginated list of users" do
      for _ <- 1..20 do
        user_fixture()
      end

      {:ok, %{users: users} = page} = Users.paginate_users(%{})

      assert length(users) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_users/0" do
    test "returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end
  end

  describe "#get_user!/1" do
    test "returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end
  end

  describe "#create_user/1" do
    test "with valid data creates a user" do
      assert {:ok, %User{} = user} = Users.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.group_id == 42
      assert user.name == "some name"
      assert user.password == "some password"
      assert user.power_user == true
      assert user.root_user == true
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end
  end

  describe "#update_user/2" do
    test "with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Users.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.group_id == 43
      assert user.name == "some updated name"
      assert user.password == "some updated password"
      assert user.power_user == false
      assert user.root_user == false
    end

    test "with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end
  end

  describe "#delete_user/1" do
    test "deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end
  end

  describe "#change_user/1" do
    test "returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Users.create_user()

    user
  end

end
