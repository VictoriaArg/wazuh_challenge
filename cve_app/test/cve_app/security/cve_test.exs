defmodule CveApp.Security.CveTest do
  alias Ecto.Changeset
  use CveApp.DataCase, async: true

  import CveApp.Fixtures

  alias CveApp.Security.CVE

  describe "changeset/2" do
    test "generates a valid changeset for valid params" do
      valid_attributes = cve_attributes()
      assert %Changeset{valid?: true} = CVE.changeset(%CVE{}, valid_attributes)
    end

    test "validates that required fields are casted" do
      attributes = cve_attributes() |> Map.drop([:json_file])

      assert %Changeset{valid?: false} = changeset = CVE.changeset(%CVE{}, attributes)

      assert changeset.errors == [json_file: {"can't be blank", [validation: :required]}]
    end

    test "validates that cve_id has correct format" do
      attributes = cve_attributes(%{cve_id: "invalid_id"})

      assert %Changeset{valid?: false} = changeset = CVE.changeset(%CVE{}, attributes)

      assert changeset.errors == [cve_id: {"has invalid format", [validation: :format]}]
    end

    test "validate that publication_date is not in the future" do
      attributes =
        cve_attributes(%{publication_date: DateTime.utc_now() |> DateTime.add(50, :day)})

      assert %Changeset{valid?: false} = changeset = CVE.changeset(%CVE{}, attributes)

      assert changeset.errors == [publication_date: {"cannot be in the future", []}]
    end

    test "validate that json_file has correct structure" do
      json = invalid_json()

      attributes = cve_attributes(%{json_file: json})

      assert %Changeset{valid?: false} = changeset = CVE.changeset(%CVE{}, attributes)

      assert changeset.errors == [
               {:json_file, {"invalid value for json file key 'data_type'", []}},
               {:json_file, {"invalid value for json file key 'containers'", []}}
             ]
    end
  end
end
