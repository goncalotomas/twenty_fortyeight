import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :twenty_fortyeight, TwentyFortyeightWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "HORuUmP/9HiCRLGgQFiH76Q00MZ9mJAhFFA4eD8cql8RWZYis6C2xEWfFkFDz2mn",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
