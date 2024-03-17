import Config

config :nostrum,
  token: System.get_env("BEABOT_TOKEN"),
  gateway_intents: [:guild_messages, :direct_messages, :message_content]
