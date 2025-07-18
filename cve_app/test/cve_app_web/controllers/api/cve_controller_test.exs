defmodule CveAppWeb.API.CVEControllerTest do
  use CveAppWeb.ConnCase, async: true

  import CveApp.Fixtures
  alias CveApp.Security.CVEManager

  setup do
    {:ok, cve} = cve_attributes() |> CVEManager.create()
    %{cve: cve}
  end

  test "GET /api/cves lists summaries", %{conn: conn, cve: cve} do
    conn = get(conn, url(~p"/api/cves"))
    assert [%{"cve_id" => response_cve_id, "publication_date" => _}] = json_response(conn, 200)
    assert cve.cve_id == response_cve_id
  end

  test "GET /api/cves/:cve_id shows full object", %{conn: conn, cve: cve} do
    conn = get(conn, url(~p"/api/cves/#{cve.cve_id}"))
    body = json_response(conn, 200)

    assert body["cveMetadata"]["cveId"] == cve.cve_id
    assert body == cve.json_file
  end

  test "GET unknown CVE returns 404", %{conn: conn} do
    conn = get(conn, url(~p"/api/cves/#{"NON-EXISTENT-CVE"}"))
    assert response(conn, 404)
  end
end
