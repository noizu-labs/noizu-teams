defmodule NoizuTeamsWeb.ErrorJSONTest do
  use NoizuTeamsWeb.ConnCase, async: true

  test "renders 404" do
    assert NoizuTeamsWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert NoizuTeamsWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
