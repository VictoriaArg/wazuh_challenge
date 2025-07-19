defmodule CveApp.Security.CVEManager do
  @moduledoc """
  CVE Manager is a module with functions to operate with rows from the CVE table and the CVE struct.
  """

  import Ecto.Query, only: [from: 2]

  alias CveApp.Repo
  alias CveApp.Security.CVE

  @spec create(map()) :: {:ok, CVE.t()} | {:error, Ecto.Changeset.t()}
  def create(params) do
    %CVE{}
    |> CVE.changeset(params)
    |> Repo.insert()
  end

  @spec get(Ecto.UUID.t()) :: CVE.t() | nil
  def get(id) do
    Repo.get(CVE, id)
  end

  @spec get_by(term(), atom()) :: CVE.t() | nil
  def get_by(value, field) do
    Repo.get_by(CVE, [{field, value}])
  end

  @spec list() :: list(CVE.t())
  def list, do: list(nil)

  @spec list(nil | [atom()]) :: list(CVE.t()) | list | {:error, String.t()}
  def list(nil), do: list_all()
  def list([]), do: []

  def list(fields) when is_list(fields) do
    valid_fields = CVE.__schema__(:fields)

    case Enum.all?(fields, &(&1 in valid_fields)) do
      true ->
        query = from c in CVE, select: map(c, ^fields), order_by: [desc: c.publication_date]
        Repo.all(query)

      false ->
        {:error, "not valid fields"}
    end
  end

  defp list_all do
    Repo.all(from c in CVE, order_by: [desc: c.publication_date])
  end
end
