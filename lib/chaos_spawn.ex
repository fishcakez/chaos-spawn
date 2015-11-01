defmodule ChaosSpawn do
  @moduledoc """
  The app for Chaos spawn. Provides all the wrapped spawn functions.
  """
  use Application
  require Logger
  alias ChaosSpawn.ProcessSpawner
  alias ChaosSpawn.ProcessWatcher

  @process_watcher ChaosSpawn.ProcessWatcher
  @kill_loop ChaosSpawn.KillLoop

  def start(_type, _args) do
    ChaosSpawn.Supervisor.start_link
  end

  # For convience provide all 6 spawning functions
  for spawn_fun <- [:spawn, :spawn_link, :spawn_monitor] do
    @spec unquote(spawn_fun)(atom, atom, list) :: pid
    def unquote(spawn_fun)(module, fun, args) do
      args = [module, fun, args, @process_watcher]
      apply(ProcessSpawner, unquote(spawn_fun), args)
    end

    @spec unquote(spawn_fun)(fun) :: pid
    def unquote(spawn_fun)(fun) do
      apply(ProcessSpawner, unquote(spawn_fun), [fun, @process_watcher])
    end
  end

  @spec register_process(pid) :: any
  def register_process(pid) do
    ProcessWatcher.add_pid(@process_watcher, pid)
  end

  @spec process_registered?(pid) :: boolean
  def process_registered?(pid) do
    ProcessWatcher.contains_pid?(@process_watcher, pid)
  end

  @spec stop() :: any
  def stop do
    send @kill_loop, {:switch_off}
  end

  @spec start() :: any
  def start do
    send @kill_loop, {:switch_on}
  end

end
