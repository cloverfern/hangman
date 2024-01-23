defmodule Hangman.Impl.Game do
  @moduledoc """

  """

  @type t :: %__MODULE__{
    game_state: Hangman.state,
    letters: list(String.t),
    turns_left: integer(),
    used: MapSet.t(String.t),
  }

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game() :: t
  def new_game do
    %__MODULE__{
      letters: String.codepoints(Dictionary.random_word())
    }
  end
end
