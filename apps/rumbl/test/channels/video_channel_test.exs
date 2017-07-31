defmodule Rumbl.Channels.VideoChannelTest do
  use Rumbl.ChannelCase
  import Rumbl.TestHelpers

  setup do
    user = insert_user(%{name: "Kira"})
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(Rumbl.UserSocket, %{"token" => token})
    {:ok, socket: socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, video: video} do
    for body <- ~w(one two) do
      video |> build_assoc(:annotations, %{body: body}) |> Repo.insert!()
    end
    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end
end
