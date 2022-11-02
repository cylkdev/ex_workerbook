defmodule ExWorkerbook.Plugins.Header do
  @behaviour ExWorkerbook.Plugins

  @impl ExWorkerbook.Plugins
  def call(values, options \\ []) do
    if options[:headers] === false do
      Enum.reject(values, &map_row_key?/1)
    else
      values
    end
  end

  defp map_row_key?({:key, _, _, _}), do: true
  defp map_row_key?(_), do: false

end
