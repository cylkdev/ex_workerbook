defmodule ExWorkerbook.Plugins do
  @moduledoc """
  """

  alias __MODULE__

  @doc """
  A user customizable callback which is used to build the Plugins pipeline.

  This can be used to transform job values or extend metrics.

  This callback is invoked during the sheet build pipeline for each job
  before the rendering.
  """
  @callback call(list | any, Keyword.t()) :: list

  @doc """
  ...

  ## Example
    iex> ExWorkerbook.Plugins.call(%{"hello" => "world"})
    [{:key, "hello", "hello", []}, {:value, "hello", "world", []}]
  """
  def call(enum, options \\ []) do
    extra_plugins = Keyword.get(options, :plugins, default_extra_plugins())
    plugins = [Plugins.Unwrap] ++ extra_plugins

    Enum.reduce(plugins, enum, & &1.call(&2, options))
  end

  defp default_extra_plugins, do: [
    Plugins.Styles,
    Plugins.Header
  ]
end
