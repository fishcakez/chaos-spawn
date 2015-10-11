Chaos Spawn
==========
[![Build Status](https://travis-ci.org/meadsteve/chaos-spawn.svg?branch=master)](https://travis-ci.org/meadsteve/chaos-spawn)

## What and why

Inspired by netfix's chaos monkey. This library is intended to be a low level
process based equivalent. It works by replacing the ```Kernel.spawn```
functions with overidden ones that return processes that die at random. This should
force an app's supervision tree to actually work.

Currently super alpha. Probably not a good idea to use yet.

## Installation
Add the following to your mix.exs dependencies:
```elixir
defp deps do
  [ {:chaos_spawn, "~> 0.0.2"} ]
end
```
then add chaos_spawn as an application in your mix.exs:

```elixir
def application do
  [applications: [:logger, :chaos_spawn]]
end
```

## Usage

### Control
The moment the app is started chaos spawn starts potential killing processes.
This can be stopped by calling
```elixir
  ChaosSpawn.stop
```
and then later restarted with:
```elixir
  ChaosSpawn.start
```

### Registering processes to kill
By default no processes are eligible to be killed by chaos spawn. The
following documents show how to do this:

[HOWTO: Add chaos spawn using the provided helper modules](usage-automatic.md)

[HOWTO: Add chaos spawn manually](usage-manual.md)

### Config
Two keys are provided. The first ```kill_tick``` is the delay in milliseconds
that between chaos spawn checking for processes to kill.
```kill_probability``` is a float between 0 and
1 that determines the probability of a process being killed each tick.

```elixir
config :chaos_spawn, :kill_tick, 1000
config :chaos_spawn, :kill_probability, 0.1
```


## Contributing
Contributions to this repo are more than welcome. Guidlines for succesfull PRs:
* Any large changes should ideally be opened as an issue first so a disucssion can be had.
* Code should be tested.
* Code under ```lib/``` should conform to coding standards tested by https://github.com/lpil/dogma . You can test this by running ```mix dogma lib/```
