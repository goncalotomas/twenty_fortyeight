defmodule TwentyFortyeightWeb.Router do
  use TwentyFortyeightWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TwentyFortyeightWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", TwentyFortyeightWeb do
    pipe_through :browser

    live "/", TwentyFortyeightLive
  end
end
