defmodule PdferWeb.PageController do
  use PdferWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def pdf(conn, %{"url" => encoded_url}) do
    url = URI.decode(encoded_url)

    {:ok, filename}    = generate(url)
    # {:ok, pdf_content} = File.read(filename)

    IO.inspect(filename, label: "filename")

    conn
    |> put_resp_header("content-disposition", "attachment; filename=page.pdf")
    |> send_file(200, filename)
  end

  defp generate(url) do
    PdfGenerator.generate({:url, url}, generator: :chrome, prefer_system_executable: true, no_sandbox: true, page_size: "letter")
  end
end
