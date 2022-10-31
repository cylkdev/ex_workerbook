# ExWorkerbook (WIP THIS IS NOT AVAILABLE IN HEX)

Elixir workbook generator.

## Templates

To generate Workbook templates simply implement the `ExWorkerbook` behavior
and `workerbook/1` callback function to return your Workerbook configuration.
Workerbook Template configuration is a keyword list of options that describes
how to generate each `Elixlsx.Sheet` via `ExWorkerbook.Builder`.

Here's an example:

```elixir
[
  [
    name: "Our First Page",
    jobs: [
      %{
        arg: %{
          "Name" => "John",
          "Age" => 19,
          "Location" => "USA"
        },
        identifier: :horizontal,
        actions: %{},
        options: []
      }
    ]
  ]
]
```

This configuration will create our first page and render a map to the
sheet in a horizontal layout. With the `workerbook/1` callback function
you can describe the layout for your workbooks and supply the params at
runtime.

Here's an example:

```elixir
defmodule ExWorkerbook.ExampleTemplate do

  @behaviour ExWorkerbook

  @impl ExWorkerbook
  def workerbook(attrs) do
    [
      sheet("1", attrs),
      sheet("2", attrs)
    ]
  end

  defp sheet("1", attrs) do
    [
      name: "Our First Page",
      identifier: :horizontal, # global identifier
      jobs: [
        %{
          arg: %{
            "Name" => attrs.name,
            "Age" => 19,
            "Location" => "USA"
          },
          actions: %{},
          options: []
        }
      ]
    ]
  end

  defp sheet("2", attrs) do
    [
      name: "Second Page",
      jobs: [
        %{
          arg: ["role", attrs.role],
          identifier: :horizontal,
          actions: %{},
          options: [
            all: [bg_color: "#000000"],
            values: [underline: true]
          ]
        }
      ]
    ]
  end
end
```

Now you can create a new excel workbook file with params:

```elixir
ExWorkerbook.write("example.xlsx", ExWorkerbook.ExampleTemplate, %{name: "john", role: "manager"}) 
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_workerbook` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_workerbook, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ex_workerbook>.

