defmodule ExWorkerbook.Adapter.Renderer do

  @type context :: ExWorkerbook.Context.t()

  @type layout :: :horizontal | :vertical | any
  @type rows :: [tuple(), ...]
  @type options :: Keyword.t()

  @doc """
  Renders a list of tuples to a `Elixlsx.Sheet` struct via the
  specified layout.

  Returns a `ExWorkerbook.Context` struct.
  """
  @callback render(context, layout, rows, options) :: context

end
