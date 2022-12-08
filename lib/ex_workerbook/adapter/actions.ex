defmodule ExWorkerbook.Adapter.Actions do

  @type context :: ExWorkerbook.Context.t()

  @doc """
  Callback function invoked after rendering.

  It can be used to transform the final state of the rendered sheet
  or to apply common actions.
  """
  @callback convert_to_action(context, fun) :: context
  @callback convert_to_action(context, map) :: context

end
