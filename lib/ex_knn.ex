defmodule ExKnn do
  @moduledoc false

  alias CSV
  def knn(training_set, test_set, k) do
    classes = ["Iris-setosa", "Iris-versicolor", "Iris-virginica"]

    for test_instance <- test_set do
      distances =
        for row <- training_set do
          dist =
            Enum.zip(List.delete_at(row, -1), test_instance)
            |> Enum.reduce(0.0, fn {x, y}, acc ->
                (x-y)*(x-y) + acc
              end)

          row ++ [:math.sqrt(dist)]

      end
      full_row = Enum.sort_by(distances, fn [_, _, _, _, _, val] -> val end, :asc)
      {neighbors, _} = Enum.split(full_row, k)

      result = find_response(neighbors, classes)
      value =
        Map.values(result)
        |> Enum.max()

      {item, value} = Enum.find(result, fn {_, val} -> val == value end)

      IO.puts "The predicted class for sample #{inspect test_instance} is #{item}"
      IO.puts "Number of votes: #{value} out of #{k}"
    end
  end

  def find_response(neighbors, classes) do
    votes =
      classes
      |> Enum.chunk_every(1)
      |> Enum.map(fn [name] -> {name, 0} end)
      |> Map.new()

    Enum.scan(neighbors, votes, fn [_, _, _, _, type, _], acc ->
      Enum.reduce(classes, acc, fn name, acc2 ->
        if type == name do
          new_value = Map.get(acc2, name) + 1
          Map.merge(acc2, Map.new([{name, new_value}]))
        else
          acc2
        end
      end)
    end)
    |> List.last()
  end
  def load_data_set(path) do
    path
    |> Path.expand(__DIR__)
    |> File.stream!
    |> CSV.decode!
    |> Enum.take_every(1)
    |> Enum.map(&(convert_list(&1, [])))
  end

  defp convert_list([], data), do: Enum.reverse(data)

  defp convert_list([h | t], data) do
    convert_list(t, [ cast_to_float(h) |data])
  end

  defp cast_to_float(value) do
    Float.parse("#{value}")
    |> case do
      :error -> value
      {num, ""} -> num
    end
  end
end
