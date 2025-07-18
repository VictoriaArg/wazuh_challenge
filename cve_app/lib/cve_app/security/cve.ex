defmodule CveApp.Security.CVE do
  @moduledoc """
  A CVE, or Common Vulnerabilities and Exposures, is a public
  database that identifies and catalogs security vulnerabilities in software and hardware.
  It provides a unique identifier for each vulnerability,
  making it easier for organizations to share information,
  prioritize fixes, and protect their systems.

  This module contains the Ecto.schema that will represent our database entries for cves.
  """
  alias Ecto.Changeset

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          title: String.t(),
          cve_id: String.t(),
          publication_date: DateTime.t(),
          json_file: map(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @cve_id_format ~r/^CVE-\d{4}-\d{4,}$/
  @expected_data_type "CVE_RECORD"

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "cves" do
    field :title, :string
    field :cve_id, :string
    field :publication_date, :utc_datetime_usec
    field :json_file, :map

    timestamps(type: :utc_datetime)
  end

  @fields [:cve_id, :title, :publication_date, :json_file]

  @doc false
  def changeset(cve, attrs) do
    cve
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> validate_format(:cve_id, @cve_id_format)
    |> validate_not_in_future(:publication_date)
    |> validate_json_structure()
    |> unique_constraint(:cve_id)
  end

  @spec validate_not_in_future(Changeset.t(), atom()) :: Changeset.t()
  defp validate_not_in_future(changeset, field) do
    validate_change(changeset, field, fn ^field, value ->
      case DateTime.compare(value, DateTime.utc_now()) do
        :gt -> [{field, "cannot be in the future"}]
        _ -> []
      end
    end)
  end

  @spec validate_json_structure(Changeset.t()) :: Changeset.t()
  defp validate_json_structure(%Ecto.Changeset{changes: %{json_file: json_file}} = changeset) do
    errors =
      []
      |> validate_data_type(json_file["dataType"])
      |> validate_containers_content(json_file["containers"])

    Enum.reduce(errors, changeset, fn {field, message}, acc ->
      add_error(acc, field, message)
    end)
  end

  defp validate_json_structure(%Ecto.Changeset{} = changeset), do: changeset

  @spec validate_data_type(list(), String.t()) :: list()
  defp validate_data_type(errors, data_type) when data_type == @expected_data_type, do: errors

  @spec validate_data_type(list(), String.t() | term()) :: list()
  defp validate_data_type(errors, _data_type) do
    [{:json_file, "invalid value for json file key 'data_type'"} | errors]
  end

  @spec validate_containers_content(list(), map()) :: list()
  defp validate_containers_content(errors, containers) when is_map(containers) do
    if Map.has_key?(containers, "adp") || Map.has_key?(containers, "cna") do
      errors
    else
      [{"json_file", "'containers' key in json file missing expected content"} | errors]
    end
  end

  @spec validate_containers_content(list(), term()) :: list()
  defp validate_containers_content(errors, _containers),
    do: [{"json_file", "invalid value for json file key 'containers'"} | errors]
end
