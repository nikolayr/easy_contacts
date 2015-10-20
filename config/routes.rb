# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

#resources :easy_contacts, :path => "/easy_contacts"
#post "easy_contacts/new(.:format)" => "easy_contacts#create"
#delete "easy_contacts/:id(.:format)" => "easy_contacts#destroy"

#get "easy_contacts/:id" =>"easy_contacts#show"
get 'easy_contacts/:id', to: redirect { |params, request|
                     ec = EasyContact.find(params[:id])
                     "http://#{request.host_with_port}/projects/#{Project.find(ec.project_id)}/easy_contacts/#{ec.id}"
                   }

get "projects/:project_id/easy_contacts(.:format)" => "easy_contacts#index"
get "projects/:project_id/easy_contacts/new(.:format)" => "easy_contacts#new"
get "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#show"
post "projects/:project_id/easy_contacts/new(.:format)" => "easy_contacts#create"
get "projects/:project_id/easy_contacts/:id/edit(.:format)" => "easy_contacts#edit"
post "projects/:project_id/easy_contacts/:id/edit(.:format)" => "easy_contacts#update"
put "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#update"
delete "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#destroy"



#   products GET    /products(.:format)          products#index
#             POST   /products(.:format)          products#create
# new_product GET    /products/new(.:format)      products#new
#edit_product GET    /products/:id/edit(.:format) products#edit
#     product GET    /products/:id(.:format)      products#show
#             PUT    /products/:id(.:format)      products#update
#             DELETE /products/:id(.:format)      products#destroy
