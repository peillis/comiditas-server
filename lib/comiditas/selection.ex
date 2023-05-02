defmodule Comiditas.Selection do
  def compare({day1, _}, {day2, _}) when is_integer(day1) and is_integer(day2) and day1 > day2,
    do: :gt

  def compare({day1, _}, {day2, _}) when is_integer(day1) and is_integer(day2) and day1 < day2,
    do: :lt

  def compare({_, meal}, {_, meal}), do: :eq
  def compare({_, "breakfast"}, {_, _meal}), do: :lt
  def compare({_, "dinner"}, {_, _meal}), do: :gt
  def compare({_, _meal}, {_, "breakfast"}), do: :gt
  def compare({_, _meal}, {_, "dinner"}), do: :lt

  def in_range?({nil, _}, _), do: false
  def in_range?({_, r}, r), do: true
  def in_range?({r, _}, r), do: true

  def in_range?({r1, r2}, r) do
    if compare(r, r1) == :gt and compare(r, r2) == :lt do
      true
    else
      false
    end
  end

  def in_range?(_, _), do: false
end
