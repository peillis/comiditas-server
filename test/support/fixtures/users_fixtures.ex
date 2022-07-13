defmodule Comiditas.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Comiditas.Users` context.
  """

  alias Comiditas.GroupsFixtures

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    group = GroupsFixtures.group_fixture()

    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: Comiditas.AccountsFixtures.unique_user_email(),
        group_id: group.id,
        name: "some name",
        password: "some password",
        power_user: false,
        root_user: false
      })
      |> Comiditas.Users.create_user()

    user
  end
end
