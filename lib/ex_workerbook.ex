defmodule ExWorkerbook do
  @moduledoc """
  #{File.read!("./README.md")}
  """

  alias ExWorkerbook.{Builder, Context}

  @doc """
  Workerbook Template callback function
  """
  @callback workerbook(map | list) :: list()

  @doc """
  Creates a list of Sheet Builders via Workerbook template
  """
  def create(workerbook, params \\ %{}) do
    params |> workerbook.workerbook() |> Enum.reduce([], &convert_to_builders/2)
  end

  @doc """
  Renders all Sheet Builders jobs to `Elixlsx.Sheet` via the configured
  plugins, renderer, and actions.
  """
  def build(workerbook, params \\ %{}, options \\ []) do
    options = Keyword.merge(default_opts(), options)
    workerbook |> create(params) |> Enum.reduce([], &(&2 ++ [Builder.build(&1, options)]))
  end

  @doc """
  Returns a `Elixlsx.Workbook` struct with all sheets created
  by the Sheet Builders with `&build/3`.
  """
  def build_workbook(workerbook, params \\ %{}, options \\ []) do
    build_workbook(%Elixlsx.Workbook{}, workerbook, params, options)
  end

  def build_workbook(%Elixlsx.Workbook{} = workbook, workerbook, params, options) do
    workerbook |> build(params, options) |> append_sheets(workbook)
  end

  @doc """
  Build are writes a new `Elixlsx.Workbook` to file via Workerbook module
  """
  def write(filename, workerbook, params \\ %{}, options \\ []) do
    workerbook |> build_workbook(params, options) |> Elixlsx.write_to(filename)
  end

  defp convert_to_builders(config, acc) do
    sheet_name = config[:name] || "sheet_name"
    sheet = Elixlsx.Sheet.with_name(sheet_name)

    context = Context.create(%{sheet: sheet})

    builder =
      Builder.create(%{
        context: context,
        identifier: config[:identifier]
      })

    builder = insert_jobs(config[:jobs] || [], builder)

    acc ++ [builder]
  end

  defp insert_jobs(jobs, builder) do
    Enum.reduce(jobs, builder, &Builder.insert(&2, &1))
  end

  defp append_sheets(builders, workbook) do
    Enum.reduce(
      builders,
      workbook,
      &Elixlsx.Workbook.append_sheet(&2, &1.context.sheet)
    )
  end

  def default_opts, do: [
    actions_module: ExWorkerbook.Actions,
    renderer_module: ExWorkerbook.Renderer
  ]
end
