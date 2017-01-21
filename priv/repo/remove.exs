
alias Comiditas.Repo
alias Comiditas.Mealdate


import Ecto.Query, only: [from: 2]

date = Timex.now(:utc) |> Timex.shift(months: -3)
Repo.delete_all(from m in Mealdate, where: m.date < ^date)
