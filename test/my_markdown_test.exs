defmodule MyMarkdownText do
  use ExUnit.Case
  doctest MyMarkdown

  test "italicizes" do
    str = "Something *important*"
    assert MyMarkdown.to_html(str) =~ "Something <em>important</em>"
  end
end
