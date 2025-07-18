defmodule CveApp.Security.CVEManagerTest do
  use CveApp.DataCase, async: true

  import CveApp.Fixtures

  alias CveApp.Security.CVEManager
  alias CveApp.Security.CVE

  describe "create/1" do
    test "successfully creates a CVE with valid attrs" do
      valid_attrs = cve_attributes()
      assert {:ok, %CVE{} = cve} = CVEManager.create(valid_attrs)

      assert cve.cve_id == valid_attrs.cve_id
      assert cve.title == valid_attrs.title
      assert DateTime.compare(cve.publication_date, valid_attrs.publication_date) == :eq
      assert is_map(cve.json_file)
    end

    test "returns error on non unique cve_id" do
      valid_attrs = cve_attributes()
      assert {:ok, %CVE{}} = CVEManager.create(valid_attrs)

      assert {:error, %Ecto.Changeset{} = changeset} = CVEManager.create(valid_attrs)

      assert changeset.errors == [
               cve_id:
                 {"has already been taken",
                  [constraint: :unique, constraint_name: "cves_cve_id_index"]}
             ]
    end

    test "returns error changeset for invalid attrs" do
      future_date = DateTime.utc_now() |> DateTime.add(50, :day)

      invalid_attrs =
        cve_attributes(%{
          cve_id: "invalid_id",
          title: :something,
          publication_date: future_date,
          json_file: %{}
        })

      assert {:error, changeset} = CVEManager.create(invalid_attrs)

      assert %{cve_id: _, title: _, publication_date: _, json_file: _} = errors_on(changeset)
    end
  end

  describe "get/1 and get_by/2" do
    setup do
      valid_attrs = cve_attributes()
      {:ok, %CVE{} = cve} = CVEManager.create(valid_attrs)
      %{cve: cve}
    end

    test "get/1 returns the CVE when it exists", %{cve: cve} do
      assert %CVE{id: id} = CVEManager.get(cve.id)
      assert id == cve.id
    end

    test "get/1 returns nil for nonexistent id" do
      assert Ecto.UUID.generate()
             |> CVEManager.get()
             |> is_nil()
    end

    test "get_by/2 returns the CVE when matching on a field", %{cve: cve} do
      assert %CVE{cve_id: cve_id} =
               CVEManager.get_by(cve.cve_id, :cve_id)

      assert cve_id == cve.cve_id
    end

    test "get_by/2 returns nil when no match" do
      assert is_nil(CVEManager.get_by("NO-SUCH-CVE", :cve_id))
    end
  end

  describe "list/0" do
    setup do
      older =
        cve_attributes(
          cve_id: "CVE-2025-1000",
          publication_date: DateTime.utc_now()
        )
        |> CVEManager.create()

      newer =
        cve_attributes(
          cve_id: "CVE-2025-2000",
          publication_date: DateTime.utc_now()
        )
        |> CVEManager.create()

      assert {:ok, %CVE{} = _older} = older
      assert {:ok, %CVE{} = _newer} = newer

      :ok
    end

    test "returns all CVEs ordered by publication_date descending" do
      [first, second | _] = CVEManager.list()
      assert first.publication_date > second.publication_date
      assert first.cve_id == "CVE-2025-2000"
      assert second.cve_id == "CVE-2025-1000"
    end
  end
end
