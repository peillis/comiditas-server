defmodule Comiditas.CheckoutController do
  use Comiditas.Web, :controller
  use Timex

  alias Comiditas.Repo
  alias Comiditas.User
  alias Comiditas.Mealdate

  require IEx

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    checkout = %{
      :lunch => %{
        :pack => [],
        :first => [],
        :yes => [],
        :second => [],
      },
      :dinner => %{
        :pack => [],
        :first => [],
        :yes => [],
        :second => [],
      },
      :breakfast => %{
        :pack => [],
        :first => [],
        :yes => [],
        :second => [],
      },
      :packs => %{
        :breakfast => [],
        :lunch => [],
        :dinner => []
      },
      :notes => [],
      :tomorrow_notes => [],
      :date => id
    }
    users = Repo.all(from u in User, where: u.group_id==^user.group_id)

    checkout = Enum.reduce(users, checkout, fn(x, checkout) ->
      # get data from today
      mealdate = Mealdate.get_or_template(id, x)
      checkout = Enum.reduce([:lunch, :dinner], checkout, fn(meal, checkout) ->
        case Map.fetch!(mealdate, meal) do
          "pack" ->
            update_in(checkout, [meal, :pack], &(&1 ++ [x.name]))
          "1" ->
            update_in(checkout, [meal, :first], &(&1 ++ [x.name]))
          "yes" ->
            update_in(checkout, [meal, :yes], &(&1 ++ [x.name]))
          "2" ->
            update_in(checkout, [meal, :second], &(&1 ++ [x.name]))
          _ -> checkout
        end
      end)
      checkout = case Map.fetch!(mealdate, :notes) do
        nil -> checkout
        notes -> update_in(checkout, [:notes], &(&1 ++ [%{:name => x.name, :notes => notes}]))
      end
      # now get the mealdate of tomorrow
      next_date_str = id
        |> Timex.parse!("%F", :strftime)
        |> Timex.shift(days: 1)
        |> Timex.format!("%F", :strftime)
      next_mealdate = Mealdate.get_or_template(next_date_str, x)
      checkout = case Map.fetch!(next_mealdate, :breakfast) do
        "pack" ->
          update_in(checkout, [:breakfast, :pack], &(&1 ++ [x.name]))
          |> update_in([:packs, :breakfast], &(&1 ++ [x.name]))
        "1" ->
          update_in(checkout, [:breakfast, :first], &(&1 ++ [x.name]))
        "yes" ->
          update_in(checkout, [:breakfast, :yes], &(&1 ++ [x.name]))
        "2" ->
          update_in(checkout, [:breakfast, :second], &(&1 ++ [x.name]))
        _ -> checkout
      end
      checkout = Enum.reduce([:lunch, :dinner], checkout, fn(meal, checkout) ->
        case Map.fetch!(next_mealdate, meal) do
          "pack" ->
            update_in(checkout, [:packs, meal], &(&1 ++ [x.name]))
          _ -> checkout
        end
      end)
      checkout = case Map.fetch!(next_mealdate, :notes) do
        nil -> checkout
        notes -> update_in(checkout, [:tomorrow_notes], &(&1 ++ [%{:name => x.name, :notes => notes}]))
      end
    end)
    render conn, :show, data: checkout
  end

end
