defmodule Comiditas.AdminFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Comiditas.Admin` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: "some name",
        timezone: "some timezone"
      })
      |> Comiditas.Admin.create_group()

    group
  end
end
