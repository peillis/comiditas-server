defmodule Comiditas.CheckoutController do
  use Comiditas.Web, :controller

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
      :date => id
    }
    users = Repo.all(from u in User, where: u.group_id==^user.group_id)

    checkout = Enum.reduce(users, checkout, fn(x, checkout) ->
      mealdate = Mealdate.get_or_template(id, x)
      Enum.reduce([:lunch, :dinner, :breakfast], checkout, fn(meal, checkout) ->
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
    end)
    render conn, :show, data: checkout
  end

end
