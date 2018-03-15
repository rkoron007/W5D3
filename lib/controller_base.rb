require 'active_support'
require 'active_support/inflector'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response ||= false
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'NO! Double Render!' if already_built_response?
    @res.header['Location'] = url
    @res.status = 302
    @already_built_response = true
    @session.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'NO! Double Render!' if already_built_response?
    @res.headers['Content-Type'] = content_type
    @res.body = [content]
    @already_built_response = true
    @session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content

  def render(template_name)
    temp = template_name.to_s
    con = self.class.to_s.underscore
    temp_file_path = "views/#{con}/#{temp}.html.erb"
    make_temp = File.read(temp_file_path)
    render_temp = ERB.new(make_temp).result(binding)
    render_content(render_temp, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)

  end
end
