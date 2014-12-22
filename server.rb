require 'sinatra'

set :bind, '0.0.0.0'
set :port, '8000'

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end
end


get '/' do
    File.read 'views/index.html'
end

get '/:project' do
    File.read "views/#{params[:project]}.html"
end

not_found do
  '404.'
end

get '/protected' do
    protected!
    'protected'
end
