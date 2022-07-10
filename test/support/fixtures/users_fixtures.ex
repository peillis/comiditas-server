defmodule Comiditas.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Comiditas.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        group_id: 42,
        name: "some name",
        password: "some password",
        power_user: true,
        root_user: true
      })
      |> Comiditas.Users.create_user()

    user
  end
end
