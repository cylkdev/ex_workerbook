defmodule ExWorkerbook.Builder do
  defstruct [:context, :identifier, jobs: []]

  alias ExWorkerbook.{Job, Plugins}

  @enable_caching Mix.env() in [:test, :dev]

  def create(params \\ %{}) do
    struct!(__MODULE__, params)
  end

  def insert(builder, params) when is_list(params) do
    Enum.reduce(params, builder, &insert(&2, &1))
  end

  def insert(%__MODULE__{jobs: jobs} = builder, params) do
    job =
      params
      |> Map.put_new(:identifier, builder.identifier)
      |> Job.create()

    Map.put(builder, :jobs, jobs ++ [job])
  end

  @doc """

  ## Examples
  iex> sheet = Elixlsx.Sheet.with_name("example")
  ...> context = ExWorkerbook.Context.create(%{sheet: sheet})
  ...> builder = ExWorkerbook.Builder.create(%{context: context})
  ...> builder = ExWorkerbook.Builder.insert(builder, [
       %{arg: ["a", "b"], identifier: :horizontal, actions: %{row: %{height: %{"A1" => 30}}}},
       %{arg: %{"hello" => "world"}, identifier: :horizontal}
       ])
  ...> ExWorkerbook.Builder.build(builder)

  """
  def build(builder, options \\ []) do
    builder.jobs
    |> Enum.map(&put_job_result/1)
    |> Enum.reduce(builder, &render_job(&1, &2, options))
  end

  defp put_job_result(job) do
    result = Plugins.call(job.arg, job.options)
    Map.put(job, :result, result)
  end

  defp render_job(job, builder, options) do
    jobs = update_jobs(builder.jobs, job, options)
    context = context_render(builder.context, job, options)

    %__MODULE__{builder | jobs: jobs, context: context}
  end

  defp context_render(context, job, options) do
    options = Keyword.merge(job.options, options)

    context
    |> render(job, options)
    |> sheet_actions(job, options)
  end

  defp sheet_actions(context, job, options) do
    actions_module = Keyword.get(options, :actions_module, ExWorkerbook.Actions)
    actions_module.convert_to_action(context, job.actions)
  end

  defp render(context, job, options) do
    renderer_module = Keyword.get(options, :renderer_module, ExWorkerbook.Renderer)
    renderer_module.render(context, job.identifier, job.result, options)
  end

  defp update_jobs(jobs, job, options) do
    jobs
    |> Enum.drop(1)
    |> maybe_append_job(job, options)
  end

  defp maybe_append_job(acc, job, options) do
    if Keyword.get(options, :cache, @enable_caching) do
      acc ++ [job]
    else
      acc
    end
  end
end
