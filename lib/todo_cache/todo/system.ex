defmodule Todo.System do
  def start_link do
    Supervisor.start_link(
      [
        Todo.Metrics,
        Todo.ProcessRegistry,
        Todo.Cache,
        Todo.Database
      ],
      strategy: :one_for_one
    )
  end
end
