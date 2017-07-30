defmodule InfoSystem.Backends.WolframTest do
  use ExUnit.Case, async: true
  alias InfoSystem.Wolfram

  test "makes request, reports results, then terminates" do
    ref = make_ref()
    {:ok, _} = Wolfram.start_link("1 + 1", ref, self(), 1)
    assert_receive {:results, ^ref, [%InfoSystem.Result{text: "2"}]}
  end
end
