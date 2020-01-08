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

  # Our pipeline implements "maybe" authenticated. We'll use the `:ensure_auth` below for when we need to make sure someone is logged in.
  pipeline :auth do
    plug ComiditasWeb.Pipeline
  end

  # We use ensure_auth to fail if there is no one logged in
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  pipeline :power_user do
    plug ComiditasWeb.PowerUserPlug
  end

  pipeline :root_user do
    plug ComiditasWeb.RootUserPlug
  end

  scope "/", ComiditasWeb do
    pipe_through [:browser, :auth]

    get "/", SessionController, :new
    get "/login", SessionController, :new
    post "/login", SessionController, :login
    get "/logout", SessionController, :logout
  end

  scope "/", ComiditasWeb do
    pipe_through [:browser, :auth, :ensure_auth, :power_user]

    # live "/list", Live.ListView
    get "/list", PageController, :list
    get "/settings", PageController, :settings
    get "/totals", PageController, :totals
    get "/users", PageController, :users
    get "/users/:uid/edit", PageController, :edit
    put "/users/:uid", PageController, :update
    get "/users/new", PageController, :new
    post "/users", PageController, :create
  end

  scope "/", ComiditasWeb do
    pipe_through [:browser, :auth, :ensure_auth, :root_user]

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
