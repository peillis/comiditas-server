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
    plug :accepts, ["json"]
  end

  scope "/admin", Comiditas do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/groups", GroupController
    resources "/users", UserController
    resources "/mealdates", MealdateController
    resources "/templates", TemplateController
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
