defmodule ExWorkerbook.Support.Example do
  @moduledoc false

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
      name: "First Page",
      identifier: :horizontal,
      protected: true,
      jobs: [
        %{
          arg: %{
            "name" => attrs.name,
            "age" => 19,
            "location" => "USA"
          },
          actions: %{
            images: [
              [
                path: "example.jpg",
                row: 0,
                col: 0,
                width: 1,
                height: 1
              ]
            ],
            cell: %{
              pane_freeze: %{1 => 1},
              merge_cells: %{2 => 3}
            },
            col: %{
              width: %{1 => 10}
            },
            row: %{
              height: %{1 => 10}
            }
          },
          options: [
            id: %{"location" => [underline: true]},
            pos: %{1 => [bg_color: "#000000"]},
            all: [bold: true]
          ]
        }
      ]
    ]
  end

  defp sheet("2", _attrs) do
    [
      name: "Second Page",
      jobs: [
        %{
          arg: ["Hello", "World"],
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
