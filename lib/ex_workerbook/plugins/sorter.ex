defmodule ExWorkerbook.Plugins.Sorter do
  @behaviour ExWorkerbook.Adapter.Plugin

  @doc """
  Sorts the values by key, value, or function via Enum.sort_by/3.

  ## Options

    * `order` - Sets the order operation. Can be `{:key, :asc | :desc}`,
      `{:value, :asc | :desc}` or `{&fun/1, :asc | :desc | function}`

  ## Example
    iex> %{"a" => 1, "b" => 2} |> ExWorkerbook.Plugins.Unwrap.call() |> ExWorkerbook.Plugins.Sorter.call(order: {:key, :asc})
    [
      {:key, "a", "a", []},
      {:value, "a", 1, []},
      {:key, "b", "b", []},
      {:value, "b", 2, []}
    ]

    iex> %{"a" => 1, "b" => 2} |> ExWorkerbook.Plugins.Unwrap.call() |> ExWorkerbook.Plugins.Sorter.call(order: {:value, :asc})
    [
      {:value, "a", 1, []},
      {:value, "b", 2, []},
      {:key, "a", "a", []},
      {:key, "b", "b", []}
    ]

    iex> [3, 1] |> ExWorkerbook.Plugins.Unwrap.call() |> ExWorkerbook.Plugins.Sorter.call(order: {:value, :asc})
    [{:value, nil, 1, []}, {:value, nil, 3, []}]
  """
  @impl ExWorkerbook.Adapter.Plugin
  def call(values, options \\ []) do
    case options[:order] do
      nil -> values
      order -> sort_by(order, values)
    end
  end

  defp sort_by({:key, order}, values), do: Enum.sort_by(values, &row_key/1, order)
  defp sort_by({:value, order}, values), do: Enum.sort_by(values, &row_value/1, order)
  defp sort_by({fun, order}, values) when is_function(fun, 1), do: Enum.sort_by(values, fun, order)

  defp row_key({_, key, _, _}), do: key
  defp row_value({_, _, value, _}), do: value

end
