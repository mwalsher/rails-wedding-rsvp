module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def sortable(column, title = nil)
    title ||= column.to_s.titleize
    css_class = column.to_s == sort_column ? "current #{sort_direction}" : nil
    direction = column.to_s == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column.to_s, :direction => direction}, {:class => css_class, :remote => true}
  end

end
