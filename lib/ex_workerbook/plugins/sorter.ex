defmodule ExWorkerbook.Plugins.Sorter do
  @behaviour ExWorkerbook.Plugins

  @impl ExWorkerbook.Plugins
  def call(values, options \\ []) do
    case options[:order] do
      nil ->
        values

      {fun, order} when is_function(fun, 1) ->
        Enum.sort_by(values, fun, order)

      order ->
        Enum.sort_by(values, &row_id/1, order)

    end
  end

  defp row_id({_, id, _, _}), do: id

end
