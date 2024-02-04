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

  test "handles a winning game" do
    turns = [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["e", :already_used, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["l", :good_guess, 6, ["_", "e", "l", "l", "_"], ["a", "e", "l"]],
      ["h", :good_guess, 6, ["h", "e", "l", "l", "_"], ["a", "e", "h", "l"]],
      ["o", :won, 6, ["h", "e", "l", "l", "o"], ["a", "e", "h", "l", "o"]],
    ]

    test_sequence_of_moves(turns)
  end

  test "handles a losing game" do
    turns = [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["x", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "x"]],
      ["y", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "x", "y"]],
      ["z", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "x", "y", "z"]],
      ["b", :bad_guess, 2, ["_", "_", "_", "_", "_"], ["a", "b", "x", "y", "z"]],
      ["c", :bad_guess, 1, ["_", "_", "_", "_", "_"], ["a", "b", "c", "x", "y", "z"]],
      ["d", :lost, 0, ["_", "_", "_", "_", "_"], ["a", "b", "c", "d", "x", "y", "z"]],
    ]

    test_sequence_of_moves(turns)
  end

  defp test_sequence_of_moves(script) do
    game = Game.new_game("hello")

    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns_left, letters, used], game) do
    {game, tally} = Game.make_move(game, guess)

    assert tally.game_state == state
    assert tally.turns_left == turns_left
    assert tally.letters == letters
    assert tally.used == used

    game
  end

end
