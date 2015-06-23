Rails.application.routes.draw do

  mount MyEngine::Engine => "/my_engine"
end
