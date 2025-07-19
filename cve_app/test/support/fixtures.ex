defmodule CveApp.Fixtures do
  @moduledoc """
  This module contains functions needed for tests.
  """

  @cve_json_file_path "test/support/valid_cve.json"
  @cve_invalid_json_file_path "test/support/invalid_cve_changeset_errors.json"

  @spec cve_attributes(map()) :: map()
  def cve_attributes(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      cve_id: "CVE-2025-53624",
      title:
        "The Docusaurus gists plugin adds a page to your Docusaurus instance, displaying all public gists of a GitHub user. docusaurus-plugin-content-gists versions prior to 4.0.0 are vulnerable to exposing GitHub Personal Access Tokens in production build artifacts when passed through plugin configuration options. The token, intended for build-time API access only, is inadvertently included in client-side JavaScript bundles, making it accessible to anyone who can view the website's source code. This vulnerability is fixed in 4.0.0.",
      publication_date: DateTime.utc_now(),
      json_file: valid_json()
    })
  end

  @spec valid_json() :: map()
  def valid_json() do
    @cve_json_file_path
    |> File.read!()
    |> Jason.decode!()
  end

  @spec invalid_json() :: map()
  def invalid_json() do
    @cve_invalid_json_file_path
    |> File.read!()
    |> Jason.decode!()
  end
end
