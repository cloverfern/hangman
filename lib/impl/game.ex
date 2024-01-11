defmodule Hangman.Impl.Game do
  @moduledoc """

  """

  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @spec new_game() :: %Hangman.Impl.Game{
          game_state: :initializing,
          letters: [String.codepoint],
          turns_left: 7,
          used: MapSet.t()
        }
  def new_game do
    %Hangman.Impl.Game{
      letters: String.codepoints(Dictionary.random_word())
    }
  end
end
