defmodule Todo.Server do
  use GenServer, restart: :temporary

  @expiry_idle_timeout :timer.seconds(10)

  def start_link(name) do
    IO.puts("Starting to-do server for #{name}'s list.")
    GenServer.start_link(__MODULE__, name, name: via_tuple(name))
  end

  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}, @expiry_idle_timeout}
  end

  # Interface function
  def add_entry(server_pid, new_entry) do
    GenServer.cast(server_pid, {:add_entry, new_entry})
  end

  def update_entry(server_pid, new_entry) do
    GenServer.cast(server_pid, {:update_entry, new_entry})
  end

  def delete_entry(server_pid, entry_id) do
    GenServer.cast(server_pid, {:delete_entry, entry_id})
  end

  def entries(server_pid, date) do
    GenServer.call(server_pid, {:entries, date})
  end

  # Message-handler clause
  def handle_info(:timeout, {name, todo_list}) do
    IO.puts("Stopping todo server for #{name}")
    {:stop, :noraml, {name, todo_list}}
  end

  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}, @expiry_idle_timeout}
  end

  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}, @expiry_idle_timeout}
  end

  def handle_cast({:update_entry, new_entry}, {name, todo_list}) do
    {:noreply, {name, Todo.List.update_entry(todo_list, new_entry)}, @expiry_idle_timeout}
  end

  def handle_cast({:delete_entry, entry_id}, {name, todo_list}) do
    {:noreply, {name, Todo.List.delete_entry(todo_list, entry_id)}, @expiry_idle_timeout}
  end

  defp via_tuple(name), do: Todo.ProcessRegistry.via_tuple({__MODULE__, name})
end
