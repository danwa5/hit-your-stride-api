SimpleCov.start 'rails' do
  add_group 'Services', 'app/services'
  add_filter 'app/controllers/graphql_controller.rb'
  add_filter 'app/graphql'
  add_filter 'spec'
end
