defmodule CveApp.Fixtures do
  @moduledoc """
  This module contains functions needed for tests.
  """

  @cve_json_file_path "test/support/valid_cve.json"
  @cve_invalid_json_file_path "test/support/invalid_cve.json"

  @spec cve_attributes(map()) :: map()
  def cve_attributes(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      cve_id: "CVE-2025-47812",
      title:
        "Git GUI allows you to use the Git source control management tools via a GUI. A malicious repository can ship versions of sh.exe or typical textconv filter programs such as astextplain. Due to the unfortunate design of Tcl on Windows, the search path when looking for an executable always includes the current directory. The mentioned programs are invoked when the user selects Git Bash or Browse Files from the menu. This vulnerability is fixed in 2.43.7, 2.44.4, 2.45.4, 2.46.4, 2.47.3, 2.48.2, 2.49.1, and 2.50.1.",
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
