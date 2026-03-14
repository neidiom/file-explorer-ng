# frozen_string_literal: true

Rails.application.routes.draw do
  root 'index#index'
  post '/', to: 'index#upload_index'

  get  '/*path', to: 'index#show', constraints: { path: /.+/ }
  put  '/*path', to: 'index#update', constraints: { path: /.+/ }
  post '/*path', to: 'index#upload', constraints: { path: /.+/ }
  delete '/*path', to: 'index#destroy', constraints: { path: /.+/ }
end
