defmodule Comiditas.Router do
  use Comiditas.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json", "json-api"]
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: Comiditas.Auth
  end

  scope "/", Comiditas do
    pipe_through :browser
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    scope "/admin" do
      pipe_through :browser_auth
      get "/", PageController, :index
      resources "/groups", GroupController
      resources "/users", UserController
      resources "/mealdates", MealdateController
      resources "/templates", TemplateController
    end
  end

  scope "/login", Comiditas do
    pipe_through :api
    post "/", SessionController, :create
  end

  scope "/api", Comiditas do
    pipe_through :api
    resources "/mealdates", MealdateController
  end

end
