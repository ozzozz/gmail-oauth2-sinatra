require 'sinatra'
require 'oauth2'
require 'json'
require 'thin'
 
# Scopes are space separated strings
SCOPES = [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile'
].join(' ')
 
unless G_API_CLIENT = ENV['G_API_CLIENT']
  raise "You must specify the G_API_CLIENT env variable"
end
 
unless G_API_SECRET = ENV['G_API_SECRET']
  raise "You must specify the G_API_SECRET env veriable"
end
 
if BASE_URL = ENV['BASE_URL']
  SUBDIR = URI.parse(BASE_URL).path
else
  SUBDIR = '' 
end

def session_key
  G_API_CLIENT.crypt(G_API_SECRET)
end

def session_secret
  G_API_SECRET.crypt(G_API_SECRET)
end

set :sessions, key: session_key,
  domain: "localhost",
  path: "#{SUBDIR}/",
  expire_after: 14400,
  secret: session_secret
 
def client
  client ||= OAuth2::Client.new(G_API_CLIENT, G_API_SECRET, {
                :site => 'https://accounts.google.com', 
                :authorize_url => "/o/oauth2/auth", 
                :token_url => "/o/oauth2/token"
              })
end
 
get "#{SUBDIR}/" do
  @redirect_uri = redirect_uri
  @request = request
  @subdir = SUBDIR
  erb :index
end
 
get "#{SUBDIR}/auth" do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri,:scope => SCOPES,:access_type => "offline")
end
 
get "#{SUBDIR}/oauth2callback" do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = access_token.token
  @message = "Successfully authenticated with the server"
  @access_token = session[:access_token]
 
  # parsed is a handy method on an OAuth2::Response object that will 
  # intelligently try and parse the response.body
  @email = access_token.get('https://www.googleapis.com/userinfo/email').parsed
  @rawemail = @email['email']
  @profile = access_token.get('https://www.googleapis.com/oauth2/v1/userinfo').parsed
  erb :success
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = "#{SUBDIR}/oauth2callback"
  uri.query = nil
  uri.to_s
end
 
