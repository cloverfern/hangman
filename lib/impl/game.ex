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

  @spec make_move(t, String.t) :: {t, Type.tally}
  def make_move(game = %{game_state: state}, _guess)
  when state in [:won, :lost] do
    return_with_tally(game)
  end

  def make_move(game, guess) do
    game
    |> accept_guess(guess, MapSet.member?(game.used, guess), is_lowercase_a_to_z?(guess))
    |> return_with_tally()
  end

  defp accept_guess(game, _guess, _already_used=true, _valid_guess) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, _guess, _new_move, _is_valid_guess=false) do
    %{game | game_state: :invalid_guess}
  end

  defp accept_guess(game, guess,  _new_move, _valid_guess) do
    game = %{game | used: MapSet.put(game.used, guess)}
    score_guess(game, is_good_guess?(game, guess), is_game_won?(game))
  end

  defp is_lowercase_a_to_z?(char)
  when is_binary(char) and byte_size(char) == 1 do
    :binary.at(char, 0) in 97..122
  end

  defp is_lowercase_a_to_z?(_) do
    false
  end

  defp is_good_guess?(game, guess) do
    Enum.member?(game.letters, guess)
  end

  defp is_game_won?(game) do
      MapSet.subset?(MapSet.new(game.letters), game.used)
  end

  defp score_guess(game, _good_guess=true, _game_won=true) do
    %{game | game_state: :won}
  end

  defp score_guess(game = %{turns_left: 1}, _good_guess=false, _game_won=false) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _good_guess=true, _game_won=false) do
    %{game | game_state: :good_guess}
  end

  defp score_guess(game = %{turns_left: turns_left}, _good_guess=false, _game_won=false)
    when turns_left > 1 do
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort(),
    }
  end

  defp reveal_guessed_letters(game=%{game_state: :lost}) do
    game.letters
  end

  defp reveal_guessed_letters(game) do
    Enum.map(
      game.letters,
      fn letter -> reveal_letter?(letter, MapSet.member?(game.used, letter)) end
      )
  end

  defp reveal_letter?(letter, _reveal=true), do: letter
  defp reveal_letter?(_letter, _do_not_reveal), do: "_"

end
