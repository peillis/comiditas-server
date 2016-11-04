defmodule Comiditas.TemplateController do
  use Comiditas.Web, :controller

  import Ecto.Query
  alias Comiditas.Template

  def index(conn, _params) do
    case get_format(conn) do
      "html" ->
        templates = Repo.all(Template)
        render(conn, "index.html", templates: templates)
      "json-api" ->
        user = Guardian.Plug.current_resource(conn)
        templates = Repo.all(Ecto.assoc(user, :templates) |> order_by(:day))
        conn |> render %{:data => templates}
    end
  end

  def new(conn, _params) do
    changeset = Template.changeset(%Template{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"template" => template_params}) do
    changeset = Template.changeset(%Template{}, template_params)

    case Repo.insert(changeset) do
      {:ok, _template} ->
        conn
        |> put_flash(:info, "Template created successfully.")
        |> redirect(to: template_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    template = Repo.get!(Template, id)
    case get_format(conn) do
      "html" -> render(conn, "show.html", template: template)
      "json-api" -> render(conn, :show, data: template)
    end

  end

  def edit(conn, %{"id" => id}) do
    template = Repo.get!(Template, id)
    changeset = Template.changeset(template)
    render(conn, "edit.html", template: template, changeset: changeset)
  end

  def update(conn, %{"id" => id, "template" => template_params}) do
    template = Repo.get!(Template, id)
    changeset = Template.changeset(template, template_params)

    case Repo.update(changeset) do
      {:ok, template} ->
        conn
        |> put_flash(:info, "Template updated successfully.")
        |> redirect(to: template_path(conn, :show, template))
      {:error, changeset} ->
        render(conn, "edit.html", template: template, changeset: changeset)
    end
  end

  # update for json
  def update(conn, %{"id" => id, "data" => data}) do
    attrs = JaSerializer.Params.to_attributes(data)
    template = Repo.get!(Template, id)
    changeset = Template.changeset(template, attrs)

    case Repo.update(changeset) do
      {:ok, template} ->
        conn
        |> put_status(201)
        |> render(:show, data: template)
      {:error, changeset} ->
        conn
        |> put_status(422)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    template = Repo.get!(Template, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(template)

    conn
    |> put_flash(:info, "Template deleted successfully.")
    |> redirect(to: template_path(conn, :index))
  end
end
