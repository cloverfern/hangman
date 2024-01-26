defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns correct game state" do
    game = Game.new_game("Wombat")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
    assert Enum.all?(game.letters, fn letter -> letter >= "a" and letter <= "z" end)
  end

  test "state doesn't change if game is won or lost" do
    for expected_game_state <- [:won, :lost] do
      game = Game.new_game("winnerorloser")
      game = Map.put(game, :game_state, expected_game_state)

      { new_game, tally } = Game.make_move(game, "a")
      assert game == new_game
      assert tally.game_state == expected_game_state
    end
  end
end
