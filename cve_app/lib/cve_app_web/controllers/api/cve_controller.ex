defmodule CveAppWeb.API.CVEController do
  use CveAppWeb, :controller

  alias CveApp.Security.CVEManager

  @doc """
  GET /api/cves

  Returns a JSON array of all updloaded CVEs.

  Example call:
  curl -i http://localhost:4000/api/cves
  """
  def index(conn, _params) do
    cves = CVEManager.list([:cve_id, :title])

    json(conn, cves)
  end

  @doc """
  GET /api/cves/:cve_id

  Returns a JSON object with the complete CVE.

  Example call:
  curl -i http://localhost:4000/api/cves/"CVE-2025-47812"
  """
  def show(conn, %{"cve_id" => id}) do
    case CVEManager.get_by(id, :cve_id) do
      %CveApp.Security.CVE{} = cve ->
        json(conn, cve.json_file)

      nil ->
        send_resp(conn, :not_found, "")
    end
  end
end
