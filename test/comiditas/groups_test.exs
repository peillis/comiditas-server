defmodule Comiditas.GroupsTest do
  use Comiditas.DataCase

  alias Comiditas.Groups

  alias Comiditas.Groups.Group

  @valid_attrs %{name: "some name", timezone: "Europe/Madrid"}
  @update_attrs %{name: "some updated name", timezone: "America/Buenos_Aires"}
  @invalid_attrs %{name: nil, timezone: nil}

  describe "#paginate_groups/1" do
    test "returns paginated list of groups" do
      for _ <- 1..20 do
        group_fixture()
      end

      {:ok, %{groups: groups} = page} = Groups.paginate_groups(%{})

      assert length(groups) == 15
      assert page.page_number == 1
      assert page.page_size == 15
      assert page.total_pages == 2
      assert page.total_entries == 20
      assert page.distance == 5
      assert page.sort_field == "inserted_at"
      assert page.sort_direction == "desc"
    end
  end

  describe "#list_groups/0" do
    test "returns all groups" do
      group = group_fixture()
      assert Groups.list_groups() == [group]
    end
  end

  describe "#get_group!/1" do
    test "returns the group with given id" do
      group = group_fixture()
      assert Groups.get_group!(group.id) == group
    end
  end

  describe "#create_group/1" do
    test "with valid data creates a group" do
      assert {:ok, %Group{} = group} = Groups.create_group(@valid_attrs)
      assert group.name == "some name"
      assert group.timezone == "Europe/Madrid"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Groups.create_group(@invalid_attrs)
    end
  end

  describe "#update_group/2" do
    test "with valid data updates the group" do
      group = group_fixture()
      assert {:ok, group} = Groups.update_group(group, @update_attrs)
      assert %Group{} = group
      assert group.name == "some updated name"
      assert group.timezone == "America/Buenos_Aires"
    end

    test "with invalid data returns error changeset" do
      group = group_fixture()
      assert {:error, %Ecto.Changeset{}} = Groups.update_group(group, @invalid_attrs)
      assert group == Groups.get_group!(group.id)
    end
  end

  describe "#delete_group/1" do
    test "deletes the group" do
      group = group_fixture()
      assert {:ok, %Group{}} = Groups.delete_group(group)
      assert_raise Ecto.NoResultsError, fn -> Groups.get_group!(group.id) end
    end
  end

  describe "#change_group/1" do
    test "returns a group changeset" do
      group = group_fixture()
      assert %Ecto.Changeset{} = Groups.change_group(group)
    end
  end

  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Groups.create_group()

    group
  end
end
