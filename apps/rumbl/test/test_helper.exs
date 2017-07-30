Code.require_file "../../info_system/test/backends/http_client.exs", __DIR__

ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(Rumbl.Repo, :manual)

