defmodule Hangman.Impl.Game do
  @moduledoc """

  """

  alias Hangman.Type

  @type t :: %__MODULE__{
    game_state: Type.state,
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
    new_game(Dictionary.random_word())
  end

  @spec new_game(String.t) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.downcase() |> String.codepoints()
    }
  end

  @spec make_move(t, String.t) :: { t, Type.tally }
  def make_move(game = %{game_state: state}, _guess)
  when state in [:won, :lost] do
    return_with_tally(game)
  end

  def make_move(game, guess) do
    game
    |> accept_guess(guess, MapSet.member?(game.used, guess))
    |> return_with_tally()
  end

  defp accept_guess(game, _guess, _already_used=true) do
    %{ game | game_state: :already_used }
  end

  defp accept_guess(game, guess,  _already_used) do
    game = %{ game | used: MapSet.put(game.used, guess) }
    score_guess(
      game,
      Enum.member?(game.letters, guess),
      Enum.all?(game.letters, fn x -> MapSet.member?(game.used, x) end)
    )
  end

  defp return_with_tally(game) do
    { game, tally(game) }
  end

  defp tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: [],
      used: game.used |> MapSet.to_list() |> Enum.sort(),
    }
  end


  defp score_guess(game, _is_member=true, _all_guessed=true) do
    %{ game | game_state: :won }
  end

  defp score_guess(game, _is_member=false, _all_guessed=false)
  when game.turns_left <= 1 do
    %{ game | game_state: :lost, turns_left: game.turns_left - 1 }
  end

  defp score_guess(game, _is_member=true, _all_guessed=false) do
    %{ game | game_state: :good_guess }
  end

  defp score_guess(game, _is_member=false, _all_guessed=false) do
    %{ game | game_state: :wrong_guess, turns_left: game.turns_left - 1 }
  end

end
