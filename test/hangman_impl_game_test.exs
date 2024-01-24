defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns correct game state" do
    game = Game.new_game("wombat")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]

  end
end
