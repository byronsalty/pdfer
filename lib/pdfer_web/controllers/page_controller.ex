defmodule PdferWeb.PageController do
  use PdferWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def pdf(conn, _params) do
    # Generate a PDF from a template.
    # The template is located at lib/pdfer_web/templates/page/pdf.html.eex
    # The PDF will be saved to the priv/static folder.
    # The PDF will be served to the user.


    url = "https://cnn.com"
    {:ok, filename}    = PdfGenerator.generate(url, generator: :chrome, prefer_local_executable: true, page_size: "A5")
    # {:ok, pdf_content} = File.read(filename)

    conn
    |> put_resp_header("content-disposition", "attachment; filename=page.pdf")
    |> send_file(200, filename)
  end
end
