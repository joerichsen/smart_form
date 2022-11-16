ExUnit.start()

alias SmartForm.TestRepo

Application.put_env(
  :smart_form,
  TestRepo,
  adapter: Ecto.Adapters.SQLite3,
  database: "/tmp/smart_form_test.db",
  pool: Ecto.Adapters.SQL.Sandbox
)

defmodule SmartForm.TestRepo do
  use Ecto.Repo,
    otp_app: :smart_form,
    adapter: Ecto.Adapters.SQLite3
end

{:ok, _} = Ecto.Adapters.SQLite3.ensure_all_started(TestRepo.config(), :temporary)

# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.SQLite3.storage_down(TestRepo.config())
:ok = Ecto.Adapters.SQLite3.storage_up(TestRepo.config())

{:ok, _} = TestRepo.start_link()

# Run migrations
Code.require_file("./support/migrations.exs", __DIR__)
:ok = Ecto.Migrator.up(TestRepo, 0, SmartForm.Migrations, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
Process.flag(:trap_exit, true)

# Load the schemas
Code.require_file("./support/schemas.exs", __DIR__)

# Load the data case
Code.require_file("./support/data_case.exs", __DIR__)
