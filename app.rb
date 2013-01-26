
require 'rubygems'
require 'sinatra'
require 'impala'
require 'mongo'

IMPALA_HOST = 'virtualbox'
IMPALA_PORT = 21000

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  enable :sessions

  set :impala_host, 'virtualbox'
  set :impala_port, 21000

  set :mongodb_host, 'localhost'
  set :mongodb_port, 27017
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end

  def impala
    @impala ||= Impala.connect(settings.impala_host, settings.impala_port)
  end

  def mongo
    @mongo_client ||= Mongo::MongoClient.new(settings.mongodb_host,
                                             settings.mongodb_port)
    @mongo ||= @mongo_client['impala_herd']
  end
end

before '/query/new' do
  if !session[:identity]
    session[:previous_url] = request.path
    @error = 'Enter a username' + request.path
    halt erb(:login_form)
  end
end

get '/query/new' do
  erb :query_form
end

post '/query/run' do
  query = params[:query].strip
  results = impala.query(query)
  id = mongo['queries'].insert({
    :query => query,
    :created => Time.now.to_i,
    :user => username,
    :results => results
  })

  redirect to "/query/#{id}"
end

get '/query/:id' do
  @query = mongo['queries'].find_one(:_id => BSON::ObjectId(params[:id]))
  erb :query
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
