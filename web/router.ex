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

  scope "/", Comiditas do
    pipe_through :browser # Use the default browser stack
    resources "/sessions", SessionController, only: [:new, :create, :delete]

    scope "/admin" do
      get "/", PageController, :index
      resources "/groups", GroupController
      resources "/users", UserController
      resources "/mealdates", MealdateController
      resources "/templates", TemplateController
    end
  end

  scope "/api", Comiditas do
    pipe_through :api
    resources "/mealdates", MealdateController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Comiditas do
  #   pipe_through :api
  # end
end
