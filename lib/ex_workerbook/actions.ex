defmodule ExWorkerbook.Actions do
  alias Elixlsx.Sheet
  alias ExWorkerbook.Context

  def convert_to_action(%Context{} = context, fun) when is_function(fun, 1) do
    case fun.(context) do
      %Context{} ->
        context

      value ->
        raise """
        The one-arity function passed to `ExWorkerbook.Actions.convert_to_action/2`
        did not return a `ExWorkerbook.Context` struct.

        Got:

        #{inspect(value)}
        """
    end
  end

  def convert_to_action(%Context{} = context, params) when is_list(params) or is_map(params) do
    Enum.reduce(params, context, &convert_params_to_action/2)
  end

  defp convert_params_to_action({:images, images}, context) do
    sheet = Enum.reduce(images, context.sheet, &insert_image/2)
    Map.put(context, :sheet, sheet)
  end

  defp convert_params_to_action({key, val}, context) do
    Enum.reduce(val, context, &maybe_sheet_action(key, &1, &2))
  end

  defp maybe_sheet_action(:cell, {:add_data_validations, list}, context) do
    sheet = Enum.reduce(list, context.sheet, &add_data_validations/2)
    Map.put(context, :sheet, sheet)
  end

  defp maybe_sheet_action(:cell, {:merge_cells, merge_cells}, context) do
    sheet = Enum.reduce(merge_cells, context.sheet, &merge_cells/2)
    Map.put(context, :sheet, sheet)
  end

  defp maybe_sheet_action(:cell, {:pane_freeze, row_cols}, context) do
    sheet = Enum.reduce(row_cols, context.sheet, &set_pane_freeze/2)
    Map.put(context, :sheet, sheet)
  end

  defp maybe_sheet_action(:col, {:width, params}, context) do
    sheet = Enum.reduce(params, context.sheet, &set_col_width/2)
    Map.put(context, :sheet, sheet)
  end

  defp maybe_sheet_action(:row, {:height, values}, context) do
    sheet = Enum.reduce(values, context.sheet, &set_row_height/2)
    Map.put(context, :sheet, sheet)
  end

  defp maybe_sheet_action(_, _, context) do
    context
  end

  defp insert_image(attrs, sheet) do
    required_keys = [:row, :col, :path]
    args = attrs |> Keyword.take(required_keys) |> Map.new()

    Sheet.insert_image(sheet, args.row, args.col, args.path, Keyword.drop(attrs, required_keys))
  end

  defp add_data_validations(map, sheet) do
    Sheet.add_data_validations(sheet, map.from, map.to, map.values)
  end

  defp merge_cells(cells, sheet) do
    Map.put(sheet, :merge_cells, sheet.merge_cells ++ [cells])
  end

  defp set_row_height({row, height}, sheet) do
    Sheet.set_row_height(sheet, row, height)
  end

  defp set_col_width({col, width}, sheet) when is_integer(col) do
    col = Elixlsx.Util.encode_col(col)
    Sheet.set_col_width(sheet, col, width)
  end

  defp set_col_width({col, width}, sheet) do
    Sheet.set_col_width(sheet, col, width)
  end

  defp set_pane_freeze({row, col}, sheet) do
    Sheet.set_pane_freeze(sheet, row, col)
  end
end
