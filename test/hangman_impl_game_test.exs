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
    { game, _ } = Game.make_move(game, "b")
    { game, _ } = Game.make_move(game, "a")

    assert MapSet.equal?(game.used, MapSet.new(["a", "b"]))
  end

  test "a good guess is reported" do
    game = Game.new_game("wombat")
    { game, tally } = Game.make_move(game, "w")
    assert tally.game_state == :good_guess
    { _game, tally } = Game.make_move(game, "t")
    assert tally.game_state == :good_guess
  end

  test "a bad guess is reported" do
    game = Game.new_game("wombat")
    { game, tally } = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess
    assert tally.turns_left == 6
    { _game, tally } = Game.make_move(game, "z")
    assert tally.game_state == :bad_guess
    assert tally.turns_left == 5
  end

  test "a victory is reported" do
    game = Game.new_game("win")
    { game, tally } = Game.make_move(game, "w")
    assert tally.game_state == :good_guess
    { game, tally } = Game.make_move(game, "i")
    assert tally.game_state == :good_guess
    { _game, tally } = Game.make_move(game, "n")
    assert tally.game_state == :won
  end

  test "a defeat is reported" do
    game = Game.new_game("lost")
    { game, tally } = Game.make_move(game, "1")
    assert tally.game_state == :bad_guess
    { game, tally } = Game.make_move(game, "2")
    assert tally.game_state == :bad_guess
    { game, tally } = Game.make_move(game, "3")
    assert tally.game_state == :bad_guess
    { game, tally } = Game.make_move(game, "4")
    assert tally.game_state == :bad_guess
    { game, tally } = Game.make_move(game, "5")
    assert tally.game_state == :bad_guess
    { game, tally } = Game.make_move(game, "6")
    assert tally.game_state == :bad_guess
    { _game, tally } = Game.make_move(game, "7")
    assert tally.game_state == :lost
  end

  [
    ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
    ["e", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
  ]

end
