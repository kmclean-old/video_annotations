defmodule AnnotationView do
  use Rumbl.Web, :view

  alias Rumbl.UserView

  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: render_one(annotation.user, UserView, "user.json")
    }
  end
end
