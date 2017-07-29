defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "me"}

  test "converts unique_constraint on username to an error" do
    insert_user(%{username: "kira"})
    attrs = Map.put(@valid_attrs, :username, "kira")
    changeset = User.changeset(%User{}, attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end
