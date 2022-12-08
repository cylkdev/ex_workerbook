defmodule ExWorkerbook.Plugins.Sorter do
  @behaviour ExWorkerbook.Plugins

  @impl ExWorkerbook.Plugins
  def call(values, options \\ []) do
    case options[:order] do
      nil -> values
      order -> sort_by(order, values)
    end
  end

  defp sort_by({:key, order}, values), do: Enum.sort_by(values, &row_id/1, order)
  defp sort_by({:value, order}, values), do: Enum.sort_by(values, &row_value/1, order)
  defp sort_by({fun, order}, values) when is_function(fun, 1), do: Enum.sort_by(values, fun, order)

  defp row_id({_, id, _, _}), do: id
  defp row_value({_, _, value, _}), do: value

end
