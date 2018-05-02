module ApplicationHelper

  def image_url(recipe)
    ["<img src=", recipe.image, " alt=", recipe.label,">"].join.html_safe
  end
end