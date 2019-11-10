defmodule Todo.List do
  defstruct auto_id: 1, entries: Map.new()

  def new(entries \\ []) do
    Enum.reduce(entries, %Todo.List{}, fn entry, todo_list_acc ->
      add_entry(todo_list_acc, entry)
    end)
  end

  def add_entry(
        %Todo.List{entries: entries, auto_id: auto_id} = todo_list,
        entry
      ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = Map.put(entries, auto_id, entry)

    %Todo.List{todo_list | entries: new_entries, auto_id: auto_id + 1}
  end

  def entries(%Todo.List{entries: entries}, date) do
    entries
    |> Stream.filter(fn {_, entry} ->
      entry.date == date
    end)
    |> Enum.map(fn {_, entry} ->
      entry
    end)
  end

  defp update_entry(
         %Todo.List{entries: entries} = todo_list,
         entry_id,
         updater_fun
       ) do
    case entries[entry_id] do
      nil ->
        todo_list

      old_entry ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
    new_entries = Map.delete(entries, entry_id)
    %Todo.List{todo_list | entries: new_entries}
  end
end

defmodule Todo.List.CsvImporter do
  def import do
    File.stream!("./lib/todos.csv")
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn entry ->
      [date | title] = entry

      {List.to_tuple(String.split(date, "/") |> Enum.map(&String.to_integer(&1))),
       List.to_string(title)}
    end)
    |> Stream.map(fn entry_tuple ->
      %{date: elem(entry_tuple, 0), title: elem(entry_tuple, 1)}
    end)
    |> Todo.List.new()
  end
end

defimpl Collectable, for: Todo.List do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todo.List.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_, :halt), do: :ok
end
