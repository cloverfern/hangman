defmodule HangmanImplGameTest do
  use ExUnit.Case

  alias Hangman.Impl.Game

  test "new game returns correct game state" do
    game = Game.new_game("Wombat")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]

    is_lowercase_a_to_z = fn letter -> letter >= "a" and letter <= "z" end
    assert Enum.all?(game.letters, is_lowercase_a_to_z)
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

  test "a duplicate letter is reported" do
    game = Game.new_game()
    { game, _ } = Game.make_move(game, "a")
    assert game.game_state != :already_used

    { game, _ } = Game.make_move(game, "b")
    assert game.game_state != :already_used

    { game, _ } = Game.make_move(game, "a")
    assert game.game_state == :already_used
  end

  test "letters are correctly recorded" do
    game = Game.new_game()
    { game, _ } = Game.make_move(game, "a")
    assert MapSet.member?(game.used, "a") == true

    { game, _ } = Game.make_move(game, "b")
    assert MapSet.member?(game.used, "b") == true

  end
end
