require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'makeaplea'
  
  
  set :jenkins, {
      'url'  => "http://dashboard.local:8080/",
      'view' => "All"
    }

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application