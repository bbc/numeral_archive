# NumeralArchive

Designed to store metric data, with a small memory footprint.

NumeralArchive will store a series of snapshots over varying time periods, which contains a `sum` and `count` value.

The snapshots can be used to work out averages over multiple time periods. This allows us to analyse trend information about a single metric's data. E.g Is it going up, or down on average?

Over time, the granularity of the data will become less focussed, which is how the memory footprint is kept low.

## Installation

```elixir
def deps do
  [
    {:numeral_archive, git: "bbc/numeral_archive"}
  ]
end
```

## Using NumeralArchive
### Incrementing a value
Use `NumeralArchive.increment/2` to increment a value.

### Controlling granularity
Call `NumeralArchive.tick/1` at a regular time interval of your choosing. This will allow you to control the granularity of the data storage.

### Generating a summary
`NumeralArchive.summary/1` will provide you with a text based summary of the data stored.

## How it works internally
The data structure contains a `tick_counter` and a nested list of snapshots.

Each snapshot contains `sum` and `count` data. A snapshot represents a period in time.
- `count` is number of times the metric has been incremented.
- `sum` is the sum of values each time the metric is incremented.

Using the snapshot, and the location of the snapshot within the list data structure, we can calculate the average over multiple time periods.

The `tick_counter` stores a count of how many times `NumeralArchive.tick/1` is called, and based on this number, moves the snapshots through the series structure.

The series structure looks like this:
```
{
  tick_counter,
  [
    [{sum, count}, {sum, count}, {sum, count}, {sum, count}, {sum, count}],
    [{sum, count}, {sum, count}, {sum, count}, {sum, count}, {sum, count}]
  ]
}
```
