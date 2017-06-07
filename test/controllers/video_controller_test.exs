defmodule Rumbl.VideoControllerTest do
  use Rumbl.ConnCase

  alias Rumbl.Video
  @valid_attrs %{url: "https://youtu.be", title: "vid", description: "a vid"}
  @invalid_attrs %{title: "invalid"}

  setup %{conn: conn} = config do
    if username = config[:login_as] do
      user = insert_user(username: username)
      conn = assign(build_conn(), :current_user, user)
      {:ok, conn: conn, user: user}
    else
      :ok
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each([
      get(conn, video_path(conn, :new)),
      get(conn, video_path(conn, :index)),
      get(conn, video_path(conn, :show, "123")),
      get(conn, video_path(conn, :edit, "123")),
      get(conn, video_path(conn, :update, "123", %{})),
      get(conn, video_path(conn, :create, %{})),
      get(conn, video_path(conn, :delete, "123")),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  @tag login_as: "Kira"
  test "renders form for new videos", %{conn: conn} do
    conn = get conn, video_path(conn, :new)
    assert html_response(conn, 200) =~ "New video"
  end

  @tag login_as: "Kira"
  test "lists all user's videos on index", %{conn: conn, user: user} do
    user_video = insert_video(user, title: "The best video")
    other_video =
      insert_video(insert_user(username: "Other user"), title: "Other video")

    conn = get conn, video_path(conn, :index)
    assert html_response(conn, 200) =~ ~r/Listing videos/
    assert String.contains?(conn.resp_body, user_video.title)
    refute String.contains?(conn.resp_body, other_video.title)
  end

  @tag login_as: "Kira"
  test "creates user video and redirects", %{conn: conn, user: user} do
    conn = post conn, video_path(conn, :create), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :index)
    assert Repo.get_by!(Video, @valid_attrs).user_id == user.id
  end

  @tag login_as: "Kira"
  test "does not create video and renders errors when invalid", %{conn: conn} do
    count_before = video_count(Video)
    conn = post conn, video_path(conn, :create), video: @invalid_attrs
    assert html_response(conn, 200) =~ "check the errors"
    assert video_count(Video) == count_before
  end

  @tag login_as: "Kira"
  test "shows chosen resource", %{conn: conn, user: user} do
    video = insert_video(user, title: "The best video")
    conn = get conn, video_path(conn, :show, video)
    assert html_response(conn, 200) =~ "The best video"
  end

  @tag login_as: "Kira"
  test "renders page not found when id doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, video_path(conn, :show, -1)
    end
  end

  @tag login_as: "Kira"
  test "renders form for editing the chosen resource",
    %{conn: conn, user: user} do
    video = insert_video(user, title: "The best video")
    conn = get conn, video_path(conn, :edit, video)
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "Kira"
  test "updates chosen resource and redirects with valid data",
    %{conn: conn, user: user} do
    video = insert_video(user, title: "The best video")
    conn = put conn, video_path(conn, :update, video), video: @valid_attrs
    assert redirected_to(conn) == video_path(conn, :show, video)
    assert Repo.get_by(Video, @valid_attrs)
  end

  @tag login_as: "Kira"
  test"does not update and renders error with invalid data",
    %{conn: conn, user: user} do
    video = insert_video(user, title: "The best video")
    conn = put conn, video_path(conn, :update, video), video: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit video"
  end

  @tag login_as: "Kira"
  test "deletes chosen resource and redirects", %{conn: conn, user: user} do
    video = insert_video(user, title: "The best video")
    conn = delete conn, video_path(conn, :delete, video)
    assert redirected_to(conn) == video_path(conn, :index)
    refute Repo.get(Video, video.id)
  end

  defp video_count(query), do: Repo.one(from v in query, select: count(v.id))
end
