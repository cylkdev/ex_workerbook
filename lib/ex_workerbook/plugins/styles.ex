defmodule ExWorkerbook.Plugins.Styles do
  @behaviour ExWorkerbook.Plugins

  require Integer

  @impl ExWorkerbook.Plugins
  def call(values, options \\ []) do
    Enum.reduce(options, values, &maybe_transform_values/2)
  end

  defp maybe_transform_values({:all, opts}, rows) do
    merge_all_sheet_opts(rows, opts)
  end

  defp maybe_transform_values({:pos, args}, rows) do
    Enum.reduce(args, rows, &transform_values_at_position/2)
  end

  defp maybe_transform_values({:keys, opts}, rows) do
    Enum.map(rows, &transform_by_type(&1, :key, opts))
  end

  defp maybe_transform_values({:values, opts}, rows) do
    Enum.map(rows, &transform_by_type(&1, :value, opts))
  end

  defp maybe_transform_values({:id, args}, rows) do
    Enum.reduce(args, rows, &transform_values_by_id/2)
  end

  defp maybe_transform_values({action, opts}, rows) when action in [:odd, :even] do
    case rows do
      [{:key, _, _, _} | _] ->
        if action === :odd do
          transform_map_opts(rows, opts, &Integer.is_odd/1)
        else
          transform_map_opts(rows, opts, &Integer.is_even/1)
        end

      [{:value, _, _, _} | _] ->
        if action === :odd do
          transform_list_opts(rows, opts, &Integer.is_odd/1)
        else
          transform_list_opts(rows, opts, &Integer.is_even/1)
        end
    end
  end

  defp maybe_transform_values(_, rows) do
    rows
  end

  defp transform_values_by_id({id, opts}, rows) do
    Enum.reduce(rows, [], &(&2 ++ [transform_by_id(&1, id, opts)]))
  end

  defp transform_by_id(row, id, opts) do
    case row do
      {type, ^id, value, sheet_opts} ->
        {type, id, value, sheet_opts ++ opts}

      row ->
        row
    end
  end

  defp transform_by_type(row, type, opts) do
    case row do
      {^type, id, value, sheet_opts} ->
        {type, id, value, sheet_opts ++ opts}

      row ->
        row
    end
  end

  defp transform_values_at_position({pos, opts}, rows) when is_integer(pos) do
    case rows do
      [{:key, _, _, _} | _] ->
        transform_map_opts(rows, opts, &(&1 === pos))

      [{:value, _, _, _} | _] ->
        transform_list_opts(rows, opts, &(&1 === pos))

    end
  end

  defp transform_map_opts(rows, sheet_opts, selector_fun) do
    rows
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.reduce([], fn {chunk, index}, acc ->
      chunk =
        if selector_fun.(index) do
          merge_all_sheet_opts(chunk, sheet_opts)
        else
          chunk
        end

      acc ++ chunk
    end)
  end

  defp transform_list_opts(rows, opts, selector_fun) do
    rows
    |> Enum.with_index()
    |> Enum.map(fn {row, index} ->
      if selector_fun.(index) do
        merge_sheet_opts(row, opts)
      else
        row
      end
    end)
  end

  defp merge_all_sheet_opts(rows, opts) do
    Enum.map(rows, &merge_sheet_opts(&1, opts))
  end

  defp merge_sheet_opts({type, id, value, sheet_opts}, opts) do
    sheet_opts = Keyword.merge(sheet_opts, opts)
    {type, id, value, sheet_opts}
  end

end
