defmodule ExWorkerbook.Job do
  defstruct [
    :arg,
    :identifier,
    :result,
    actions: %{},
    options: []
  ]

  def create(params \\ %{})
  def create(params) when is_list(params), do: params |> Map.new() |> create()
  def create(params), do: struct!(__MODULE__, params)
end
