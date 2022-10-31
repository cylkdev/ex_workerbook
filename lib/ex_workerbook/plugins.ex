defmodule ExWorkerbook.Plugins do
  alias __MODULE__

  @callback call(map | list, Keyword.t()) :: list

  def call(enum, options \\ []) do
    extra_plugins = Keyword.get(options, :plugins, default_extra_plugins())
    plugins = [Plugins.Unwrap] ++ extra_plugins

    Enum.reduce(plugins, enum, & &1.call(&2, options))
  end

  defp default_extra_plugins, do: [Plugins.Styles]
end
