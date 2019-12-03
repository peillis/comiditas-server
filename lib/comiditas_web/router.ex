defmodule ComiditasWeb.Router do
  use ComiditasWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ComiditasWeb do
    pipe_through :browser

    get "/", PageController, :index

    scope "/admin" do
      resources "/groups", GroupController
      resources "/users", UserController
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ComiditasWeb do
  #   pipe_through :api
  # end
end
