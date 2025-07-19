defmodule CveAppWeb.IndexLive do
  use CveAppWeb, :live_view

  alias CveApp.Security.CVE
  alias CveApp.Security.CVEManager

  @impl true
  def mount(_params, _session, socket) do
    socket =
      allow_upload(socket, :json_file,
        accept: ~w(.json),
        max_entries: 1,
        max_file_size: 2_000_000
      )

    mounted_socket =
      socket
      |> assign(:upload_error, nil)

    {:ok, mounted_socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("save", _params, socket) do
    entries =
      consume_uploaded_entries(socket, :json_file, fn %{path: path}, _entry ->
        with {:ok, content} <- File.read(path),
             {:ok, json} <- Jason.decode(content) do
          {:ok, json}
        else
          {:error, %Jason.DecodeError{} = decode_err} ->
            {:error, {:invalid_json, decode_err}}

          {:error, read_err} ->
            {:error, {:file_read, read_err}}
        end
      end)

    file_consumption_result =
      case entries do
        [] ->
          {:error, :no_file}

        [json] when is_map(json) ->
          {:ok, json}

        [{:error, reason}] ->
          {:error, reason}
      end

    {:noreply, validate_result(file_consumption_result, socket)}
  end

  @spec validate_result(tuple(), Phoenix.Socket.t()) :: Phoenix.Socket.t()
  defp validate_result({:ok, json}, socket) do
    case cve_from_json(json) do
      {:ok, %CVE{}} ->
        ## ASSIGN NEW CV TO FUTURE TABLE SO IT REFRESHES
        put_flash(socket, :info, "CVE uploaded successfully.")

      {:error, %Ecto.Changeset{} = changeset} ->
        errors = changeset_errors_to_string(changeset)
        put_flash(socket, :error, errors)

      {:error, {:invalid_json, _json}} = error ->
        validate_result(error, socket)
    end
  end

  defp validate_result({:error, :no_file}, socket),
    do: put_flash(socket, :error, "No file was uploaded.")

  defp validate_result({:error, {:invalid_json, _}}, socket),
    do: put_flash(socket, :error, "Uploaded file is not valid JSON.")

  defp validate_result({:error, {:file_read, _}}, socket),
    do: put_flash(socket, :error, "Unable to read uploaded file.")

  defp validate_result({:error, _}, socket),
    do: put_flash(socket, :error, "An unknown error occurred during upload.")

  @spec changeset_errors_to_string(Ecto.Changeset.t()) :: String.t()
  defp changeset_errors_to_string(changeset) do
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map(fn {field, messages} ->
        Enum.map(messages, fn msg -> "#{field}: #{msg}" end)
      end)
      |> List.flatten()
      |> Enum.join(", ")

    "CVE not created, file with errors: " <> errors
  end

  @spec cve_from_json(map()) :: {:ok, CVE.t()} | {:error, term()}
  def cve_from_json(json) do
    with {:ok, params} <- pattern_match_params(json),
         %Ecto.Changeset{valid?: true} <- CVE.changeset(%CVE{}, params) do
      CVEManager.create(params)
    else
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      {:error, {:invalid_json, _json}} = error ->
        error
    end
  end

  @spec pattern_match_params(map()) :: {:ok, map()} | {:error, term()}
  defp pattern_match_params(
         %{
           "containers" => %{
             "cna" => %{
               "descriptions" => descriptions
             }
           },
           "cveMetadata" => %{
             "cveId" => cve_id,
             "datePublished" => publication_date
           }
         } = json
       )
       when is_list(descriptions) do
    title =
      Enum.find_value(descriptions, fn
        %{"lang" => "en", "value" => value} -> value
        _ -> nil
      end)

    {:ok,
     %{
       title: title,
       cve_id: cve_id,
       publication_date: publication_date,
       json_file: json
     }}
  end

  defp pattern_match_params(json),
    do: {:error, {:invalid_json, json}}
end
