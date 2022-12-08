defmodule ExWorkerbook.Plugins do
  @moduledoc """
  """

  alias ExWorkerbook.Plugins

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
    Plugins.Sorter,
    Plugins.Styles,
    Plugins.Header,
  ]
end
