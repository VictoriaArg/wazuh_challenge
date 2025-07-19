defmodule CveAppWeb.IndexLiveTest do
  use CveAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import CveApp.Fixtures

  alias CveApp.Security.CVE
  alias CveApp.Security.CVEManager

  describe "index live with empty cves table" do
    test "visiting index for the first time", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      render = render(index_live)

      assert render =~ "CVEs Index"

      assert render =~
               "Here you will be able to upload new CVEs files and see them listed in the table below."

      assert render =~ "Upload CVE JSON"
      assert render =~ "There are no files to display"
      assert render =~ "Upload new cve files to vizualise their information."

      assert has_element?(index_live, "button#submit-file-button[type=submit]")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]
    end

    test "succesfully uploading first cve file", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      assert render(index_live) =~ "There are no files to display"

      file_upload =
        file_input(index_live, "#upload-cves-form", :json_file, [
          local_upload_mock(:valid_file)
        ])

      read_file_render = render_upload(file_upload, "valid_cve.json")

      assert [{"button", _, _} = button] =
               read_file_render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == []

      assert index_live
             |> form("#upload-cves-form", %{})
             |> render_submit()

      render = render(index_live)
      assert render =~ "CVE uploaded successfully."
      refute render =~ "There are no files to display"
      refute has_element?(index_live, "#empty-state-container")
      assert has_element?(index_live, "#table-container")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]

      assert [{"p", _, _} = cve_id_in_table] =
               render
               |> Floki.parse_document!()
               |> Floki.find("p.text-nowrap.w-full")

      # cveId value from support json file
      expected_cve_id = "CVE-2025-53624"

      assert Floki.text(cve_id_in_table) == expected_cve_id

      %CVE{cve_id: uploaded_cve_id} = CVEManager.get_by(expected_cve_id, :cve_id)

      assert uploaded_cve_id == expected_cve_id
    end
  end

  describe "index live with cves table previously filled" do
    setup do
      valid_attrs = cve_attributes(%{cve_id: "CVE-2025-00000"})

      {:ok, %CVE{} = cve} = CVEManager.create(valid_attrs)

      %{cve: cve}
    end

    test "visiting index for the first time", %{conn: conn, cve: cve} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      render = render(index_live)

      assert render =~ "CVEs Index"

      assert render =~
               "Here you will be able to upload new CVEs files and see them listed in the table below."

      assert render =~ "Upload CVE JSON"
      refute render =~ "There are no files to display"
      refute render =~ "Upload new cve files to vizualise their information."
      assert render =~ cve.cve_id

      assert has_element?(index_live, "button#submit-file-button[type=submit]")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]
    end

    test "succesfully uploading second cve file", %{conn: conn, cve: cve} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      file_upload =
        file_input(index_live, "#upload-cves-form", :json_file, [
          local_upload_mock(:valid_file)
        ])

      read_file_render = render_upload(file_upload, "valid_cve.json")

      assert [{"button", _, _} = button] =
               read_file_render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == []

      assert index_live
             |> form("#upload-cves-form", %{})
             |> render_submit()

      render = render(index_live)
      assert render =~ "CVE uploaded successfully."
      refute has_element?(index_live, "#empty-state-container")
      assert has_element?(index_live, "#table-container")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]

      assert [{"p", _, _} = old_cve, {"p", _, _} = newest_cve] =
               render
               |> Floki.parse_document!()
               |> Floki.find("p.text-nowrap.w-full")

      # cveId value from support json file
      expected_new_cve_id = "CVE-2025-53624"

      assert Floki.text(newest_cve) == expected_new_cve_id
      assert Floki.text(old_cve) == cve.cve_id
      %CVE{cve_id: new_cve_id_in_db} = CVEManager.get_by(expected_new_cve_id, :cve_id)
      assert expected_new_cve_id == new_cve_id_in_db
    end
  end

  describe "index live: attempting to upload invalid files" do
    test "returns error on attepmting to upload a file with content error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      file_upload =
        file_input(index_live, "#upload-cves-form", :json_file, [
          local_upload_mock(:content_error_file)
        ])

      read_file_render = render_upload(file_upload, "invalid_cve_content_error.json")

      assert [{"button", _, _} = button] =
               read_file_render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == []

      assert index_live
             |> form("#upload-cves-form", %{})
             |> render_submit()

      render = render(index_live)
      assert render =~ "Uploaded file is not valid JSON."
      assert has_element?(index_live, "#empty-state-container")
      refute has_element?(index_live, "#table-container")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]

      assert CVEManager.list() == []
    end

    test "returns error on attepmting to upload a file with format error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      file_upload =
        file_input(index_live, "#upload-cves-form", :json_file, [
          local_upload_mock(:format_error_file)
        ])

      read_file_render = render_upload(file_upload, "invalid_cve_format_error.json")

      assert [{"button", _, _} = button] =
               read_file_render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == []

      assert index_live
             |> form("#upload-cves-form", %{})
             |> render_submit()

      render = render(index_live)
      assert render =~ "Uploaded file is not valid JSON."
      assert has_element?(index_live, "#empty-state-container")
      refute has_element?(index_live, "#table-container")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]

      assert CVEManager.list() == []
    end

    test "returns error on attepmting to upload a file with values error", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/")

      file_upload =
        file_input(index_live, "#upload-cves-form", :json_file, [
          local_upload_mock(:changeset_error_file)
        ])

      read_file_render = render_upload(file_upload, "invalid_cve_changeset_errors.json")

      assert [{"button", _, _} = button] =
               read_file_render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == []

      assert index_live
             |> form("#upload-cves-form", %{})
             |> render_submit()

      render = render(index_live)

      assert render =~ "CVE not created, file with errors: "
      assert render =~ "json_file: invalid value for json file key &#39;data_type&#39"
      assert render =~ "cve_id: has invalid format"
      assert render =~ "publication_date: cannot be in the future"

      assert has_element?(index_live, "#empty-state-container")
      refute has_element?(index_live, "#table-container")

      assert [{"button", _, _} = button] =
               render
               |> Floki.parse_document!()
               |> Floki.find("#submit-file-button")

      assert Floki.attribute(button, "disabled") == ["disabled"]

      assert CVEManager.list() == []
    end
  end

  defp local_upload_mock(:valid_file) do
    %{
      name: "valid_cve.json",
      content: File.read!("test/support/valid_cve.json")
    }
  end

  defp local_upload_mock(:format_error_file) do
    %{
      name: "invalid_cve_format_error.json",
      content: File.read!("test/support/invalid_cve_format_error.json")
    }
  end

  defp local_upload_mock(:content_error_file) do
    %{
      name: "invalid_cve_content_error.json",
      content: File.read!("test/support/invalid_cve_content_error.json")
    }
  end

  defp local_upload_mock(:changeset_error_file) do
    %{
      name: "invalid_cve_changeset_errors.json",
      content: File.read!("test/support/invalid_cve_changeset_errors.json")
    }
  end
end
