# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Comiditas.Repo.insert!(%Comiditas.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Comiditas.Repo

alias Comiditas.Group
alias Comiditas.User
alias Comiditas.Mealdate

group = Repo.insert!(%Group{name: "salces"})

cs = User.registration_changeset(%User{},
    %{email: "e@h.es", password: "kikoki", name: "enrique"})
cs = cs |> Ecto.Changeset.put_assoc(:group, group)

user = Repo.insert!(cs)

Repo.insert!(%Mealdate{user_id: user.id,
  date: Ecto.Date.cast!("2016-09-12"),
  breakfast: "1",
  lunch: "yes",
  dinner: "no"})

Enum.each(["13", "14", "15", "16", "17", "18", "19", "20", "21", "22"], fn(x)->
  Repo.insert!(%Mealdate{user_id: user.id,
    date: Ecto.Date.cast!("2016-09-#{x}"),
    breakfast: "1",
    lunch: "yes",
    dinner: "yes"})
  end
)
