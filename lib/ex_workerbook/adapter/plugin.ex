defmodule ExWorkerbook.Adapter.Plugin do

  @doc """
  Callback function invoked per unwrapped set of values

  It can be used to transform the values before rendering to a sheet.
  It is expected to return a list of unwrapped values or a list.
  """
  @callback call(list | any, Keyword.t()) :: list

end
