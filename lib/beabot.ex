defmodule BeabotConsumer do
  @moduledoc """
  Documentation for `Beabot`.
  """

  use Nostrum.Consumer

  alias Beatbot.CardValues

  alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # IO.inspect(msg)

    # If the message comes from a channel, the msg.content contains an ID.
    # Otherwise, it just contains the message (in a DM style conversation).
    # We're going to split the msg.content into separate strings and if the length
    # is > 1, ignore the id and just pass the command on.
    # Eventually, we'll parse out any opts and pass those along to the functions for
    # things like sub-commands to add new items or control the chance of generating
    # certain sub-prompts

    split_message = String.split(msg.content, " ")

    %{command: command, opts: opts} =
      split_message |> parse_message

    case command do
      "!ping" ->
        # IO.puts("inside ping")
        Api.create_message(msg.channel_id, "Pong!")

      "!bea" ->
        # build the message with be_a then send it to the channel
        Api.create_message(msg.channel_id, be_a(opts))

      "!help" ->
        message = """
        BeaBot creates an acting prompt for you to practice drills. The default configuration
        will create a character, followed by random chances to add an emotion, a control space,
        a center of gravity (for movement) and an action. Others may be added later.\n
        To have BeaBot create a prompt, simply type !bea in the chat. You may also have a private
        DM session using the same command.
        BeaBot is heavily inspired by a small subset of exercises and drills performed at
        The Acting Center is Sherman Oaks, CA. Please check them out at http://www.theactingcenterla.com
        for more information!
        """

        Api.create_message(msg.channel_id, message)

      _ ->
        IO.puts("I don't know what this is: " <> msg.content <> "\n")
        :ignore
    end
  end

  # primary driver of the prompt builder. _opts will contain the remainder of the calling string
  # that will eventually be validated and used. The current idea will be <keyword> <switch>.
  # For example: !bea emotion 10 would send 10 to emotion, which will be used in the chance the prompt will
  # use it.
  defp be_a(_opts \\ []) do
    # TODO: split opts
    # still thinking about opts. I think it should look like ["character", <int>, "emotion", <int>, ...]
    # we'll have some overriding commands like !bea2 that will pass in different sets of default values to make
    # calling common ones easier, like character + emotion + action only, etc. Those will simply call this one
    # with the appropriate weights populated.
    "Ready?\n.\n.\n.\n" <>
      CardValues.get_character() <>
      CardValues.get_emotion() <>
      CardValues.get_space() <>
      CardValues.get_center_of_gravity() <>
      CardValues.get_action()
  end

  # Handles both direct message and channel communication to strip out
  # id when necessary
  defp parse_message(message) do
    # temp_map = %{command: nil, opts: nil}

    if length(message) > 1 do
      [_some_id, command | opts] = message
      %{command: command, opts: opts}
    else
      # IO.puts(msg.content)
      [command | opts] = message
      %{command: command, opts: opts}
    end
  end

  defp parse_options(options) do
    # handle the empty list (no options passed)
    # question: Should I build a hashmap? %{action: 7, cog: 8...}
    case options do
      [] -> %{}
    end
  end
end
