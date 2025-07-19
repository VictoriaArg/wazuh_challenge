defmodule CveAppWeb.IndexLive do
  use CveAppWeb, :live_view

  # alias CveApp.Security.CVE
  # alias CveApp.Security.CVEManager

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
      consume_uploaded_entries(socket, :json_file, fn %{path: path}, entry ->
        IO.inspect(path, label: "ENTRy")

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

    result =
      case entries do
        [] ->
          {:error, :no_file}

        [json] when is_map(json) ->
          {:ok, json}

        [{:error, reason}] ->
          {:error, reason}
      end

    IO.inspect(entries, label: "ENTRIES")
    IO.inspect(result, label: "RESULT")

    socket =
      case result do
        {:ok, _json} ->
          put_flash(socket, :info, "CVE uploaded successfully.")

        {:error, :no_file} ->
          put_flash(socket, :error, "No file was uploaded.")

        {:error, {:invalid_json, _}} ->
          put_flash(socket, :error, "Uploaded file is not valid JSON.")

        {:error, {:file_read, _}} ->
          put_flash(socket, :error, "Unable to read uploaded file.")

        {:error, _} ->
          put_flash(socket, :error, "An unknown error occurred during upload.")
      end

    {:noreply, socket}
  end
end
