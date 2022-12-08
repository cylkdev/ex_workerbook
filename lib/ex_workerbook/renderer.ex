defmodule ExWorkerbook.Renderer do
  @behaviour ExWorkerbook.Adapter.Renderer

  alias ExWorkerbook.Context

  @type context :: Context.t()

  @type params :: map
  @type layout :: :horizontal | :vertical | any
  @type rows :: [tuple(), ...]
  @type options :: Keyword.t()

  @doc """
  Renders a list of tuples to a `Elixlsx.Sheet` struct via the
  specified layout.

  Returns a `ExWorkerbook.Context` struct.

  Raises if the value is not a list of tuples that starts with
  `{:key, _, _, _}` or `{:value, _, _, _}`.
  """
  @impl ExWorkerbook.Adapter.Renderer
  @spec render(context, layout, rows, options) :: context
  def render(%Context{} = context, layout, values, options \\ []) do
    case values do
      [{:key, _, _, _} | _] = values ->
        render_unwrapped_map_values(context, layout, values, options)

      [{:value, _, _, _} | _] = values ->
        render_list_values(context, layout, values, options)

      value ->
        raise """
        [#{__MODULE__}] Unable to render values due to to an unknown format.

        Expected value to be a unwrapped enumerable.

        For example a list of key/value tuples:

        [{:key, _, _, _}, {:value, _, _, _}, ...]

        or a list of value tuples:

        [{:value, _, _, _}, ...]

        Got:

        #{inspect(value)}

        To unwrap and render an enumerable call `ExWorkerbook.Pipeline.Unwrap.call/2`
        and then call the render function.

        For example:

        ```
        iex> values = ExWorkerbook.Plugins.Unwrap.call(["foo", "bar"])

        ...> context = ExWorkerbook.Context.create(%{sheet: Elixlsx.Sheet.with_name("example")})

        ...> ExWorkerbook.Renderer.render(context, :horizontal, values)
        ```
        """
    end
  end

  defp render_list_values(context, :horizontal, values, options) do
    values
    |> Enum.with_index()
    |> Enum.reduce(context, &set_list_value_horiz(&1, &2))
    |> inc_row()
    |> maybe_transform_row_col(options)
  end

  defp render_list_values(context, :vertical, values, options) do
    values
    |> Enum.with_index(context.row)
    |> Enum.reduce(context, &set_list_value_vert(&1, &2))
    |> inc_row()
    |> maybe_transform_row_col(options)
  end

  defp set_list_value_vert({{_, _, value, sheet_options}, row}, context) do
    %Context{
      context
      | row: row,
        col: context.col,
        sheet: Elixlsx.Sheet.set_at(context.sheet, row, context.col, value, sheet_options)
    }
  end

  defp set_list_value_horiz({{_, _, value, sheet_options}, col}, context) do
    %Context{
      context
      | col: col,
        sheet: Elixlsx.Sheet.set_at(context.sheet, context.row, col, value, sheet_options)
    }
  end

  defp render_unwrapped_map_values(context, :horizontal, values, options) do
    values
    |> Enum.chunk_every(2)
    |> Enum.with_index()
    |> Enum.reduce(context, &index_and_set_map_chunk_horiz(&1, context.row, &2))
    |> inc_row()
    |> maybe_transform_row_col(options)
  end

  defp render_unwrapped_map_values(context, :vertical, values, options) do
    values
    |> Enum.chunk_every(2)
    |> Enum.with_index(context.row)
    |> Enum.reduce(context, &index_and_set_map_chunk_vert(&1, &2))
    |> inc_row()
    |> maybe_transform_row_col(options)
  end

  defp index_and_set_map_chunk_horiz({chunk, col}, row, context) do
    chunk
    |> Enum.with_index(row)
    |> Enum.reduce(context, &set_map_value_horiz(&1, col, &2))
  end

  defp index_and_set_map_chunk_vert({chunk, row}, context) do
    chunk
    |> Enum.with_index()
    |> Enum.reduce(context, &set_map_value_vert(&1, row, &2))
  end

  defp set_map_value_horiz({{_, _, value, sheet_options}, row}, col, context) do
    %Context{
      context
      | row: row,
        col: col,
        sheet: Elixlsx.Sheet.set_at(context.sheet, row, col, value, sheet_options)
    }
  end

  defp set_map_value_vert({{_, _, value, sheet_options}, col}, row, context) do
    %Context{
      context
      | row: row,
        col: col,
        sheet: Elixlsx.Sheet.set_at(context.sheet, row, col, value, sheet_options)
    }
  end

  defp inc_row(context) do
    Map.put(context, :row, context.row + 1)
  end

  defp maybe_transform_row_col(%Context{row: row, col: col} = context, options) do
    case options[:offset] do
      nil ->
        context

      params when is_map(params) ->
        row = offset_or_default(params, :row, row)
        col = offset_or_default(params, :col, col)

        %Context{context | row: row, col: col}
    end
  end

  defp offset_or_default(params, row_or_col, num) do
    case Map.get(params, row_or_col, num) do
      params when is_map(params) ->
        maybe_transform_num(params, num)

      value when is_integer(value) ->
        value
    end
  end

  defp maybe_transform_num(params, num) do
    Enum.reduce(params, num, &apply_kernel_fun/2)
  end

  defp apply_kernel_fun({fun, val}, acc) when fun in [:+, :-, :/, :*] do
    apply(Kernel, fun, [acc, val])
  end
end
