
require 'rubygems'
require 'sinatra'

IMPALA_HOST = 'virtualbox'
IMPALA_PORT = 21000

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/query/new' do
  if !session[:identity]
    session[:previous_url] = request.path
    @error = 'Enter a username' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'A LIST OF QUERIES WILL GO HERE'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end
