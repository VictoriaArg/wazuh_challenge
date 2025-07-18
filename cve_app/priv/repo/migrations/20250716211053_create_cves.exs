defmodule YourApp.Repo.Migrations.CreateCves do
  use Ecto.Migration

  def change do
    create table(:cves, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :cve_id, :string, null: false
      add :title, :text
      add :publication_date, :utc_datetime_usec
      add :json_file, :map

      timestamps()
    end

    create unique_index(:cves, [:cve_id])
    create unique_index(:cves, [:id])
  end
end
