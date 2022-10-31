defmodule ExWorkerbook.Context do
  @doc """
  ExWorkerbook Cursor Context
  """
  defstruct [:sheet, col: 0, row: 0]

  @type t :: %__MODULE__{}

  @type params :: map

  @doc """
  Returns a struct

  Raises if params contains a key not defined in the struct.
  """
  @spec create(params) :: t
  def create(params \\ %{}) do
    struct!(__MODULE__, params)
  end
end
