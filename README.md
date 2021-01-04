# NumeralArchive

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lossy_average` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:numeral_archive, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lossy_average](https://hexdocs.pm/lossy_average).


## How it works
Stores a series of averages over varying time periods (granularities).

This allows us to analyse trend information about a single metric's data.

E.g Is it going up, or down on average?

The `tick counter`, counts how many times the `NumeralArchive.tick/1` function has been called. This should be called
upon a regular time interval. This number is used to know when to move the averages onto the next slot.

For example, each time the `NumeralArchive.tick/1` is called, then

Time Interval (TI) - Frequency that `NumeralArchive.tick/1` is called.
```
{<< tick counter >>,
 [
   [{<< sum 0m->(TI) >>, << count 0m->(TI) >>}, << average (TI)->(TI * 2) >>, << average (TI * 2)->(TI * 3) >>, << average (TI * 3)->(TI * 4) >>, << average (TI * 4)->(TI * 5) >>],
   [<< average (TI * 5)->(TI * 10) >>, << average (TI * 10)->(TI * 15) >>, << average (TI * 15)->(TI * 20) >>, << average (TI * 20)->(TI * 25) >>, << average (TI * 25)->(TI * 30) >>]
 ]}
```

For example, if the Time Interval was set to 1 minute:
```
{<< tick counter >>,
 [
   [{<< sum 0m->1m >>, << count 0m->1m >>}, << average 1m->2m >>, << average 2m->3m >>, << average 3m->4m >>, << average 4m->5m >>],
   [<< average 5m->10m >>, << average 10m->15m >>, << average 15m->20m >>, << average 20m->25m >>, << average 25m->30m >>]
 ]}
```

and if the Time Interval was set to 10 minutes:
```
{<< tick counter >>,
 [
   [{<< sum 0m->10m >>, << count 0m->10m >>}, << average 10m->20m >>, << average 20m->30m >>, << average 30m->40m >>, << average 40m->50m >>],
   [<< average 50m->100m >>, << average 100m->150m >>, << average 150m->200m >>, << average 200m->250m >>, << average 250m->300m >>]
 ]}
```
