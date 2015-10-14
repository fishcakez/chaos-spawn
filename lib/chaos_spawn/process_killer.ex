defmodule ChaosSpawn.ProcessKiller do
  @moduledoc """
  Module responsible for waiting and randomly killing processes.
  Is dependent on being given a ChaosSpawn.ProcessWatcher to discover
  proceses it can kill.
  """

  require Logger
  alias ChaosSpawn.ProcessWatcher
  alias ChaosSpawn.Time
  alias ChaosSpawn.Config

  def start_link(interval, probability, watcher, name: pid_name) do
    pid = spawn(fn -> kill_loop(interval, probability, watcher) end)
    Process.register pid, pid_name
    {:ok, pid}
  end

  def start_link(interval, probability, watcher) do
    start_link(interval, probability, watcher, name: ChaosSpawn.ProcessKiller)
  end

  def kill(pid), do: kill(pid, Config.kill_config)

  def kill(pid, only_kill_between: {start_time, end_time}) do
    in_killing_window? = Time.now |> Time.between?(start_time, end_time)
    if in_killing_window?, do: kill(pid, [])
  end

  def kill(pid, []) do
    Logger.debug("Killing pid #{inspect pid}")
    Process.exit(pid, :kill)
  end

  defp kill_loop(interval, probability, process_watcher, active \\ true) do
    :timer.sleep(interval)
    remain_active = still_active?(active)
    if remain_active and (:random.uniform <= probability) do
      fetch_and_kill(process_watcher)
    end
    kill_loop(interval, probability, process_watcher, remain_active)
  end

  defp still_active?(active) when is_boolean(active)  do
    receive do
      {:switch_on}  -> still_active?(true)
      {:switch_off} -> still_active?(false)
    after
      0_001         -> active # No more messages
    end
  end

  defp fetch_and_kill(process_watcher) do
    Logger.debug("Finding a process to kill")
    pid = ProcessWatcher.get_random_pid(process_watcher)
    case pid do
      :none -> Logger.debug("no pids to kill")
      pid   -> kill(pid)
    end
  end

end
