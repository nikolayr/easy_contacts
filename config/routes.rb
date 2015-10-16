# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
match "projects/:project_id/easy_contacts" => "easy_contacts#index", :as => :easy_contacts


get "projects/:project_id/easy_contacts(.:format)" => "easy_contacts#index", :as => :easy_contacts
get "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#show", :as => :easy_contacts
get "projects/:project_id/easy_contacts/new(.:format)" => "easy_contacts#new", :as => :easy_contacts
post "projects/:project_id/easy_contacts(.:format)" => "easy_contacts#create", :as => :easy_contacts
get "projects/:project_id/easy_contacts/:id/edit(.:format)" => "easy_contacts#edit",:as => :easy_contacts
put "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#update",:as => :easy_contacts
delete "projects/:project_id/easy_contacts/:id(.:format)" => "easy_contacts#destroy",:as => :easy_contacts


#   products GET    /products(.:format)          products#index
#             POST   /products(.:format)          products#create
# new_product GET    /products/new(.:format)      products#new
#edit_product GET    /products/:id/edit(.:format) products#edit
#     product GET    /products/:id(.:format)      products#show
#             PUT    /products/:id(.:format)      products#update
#             DELETE /products/:id(.:format)      products#destroy


#10.16.91.128/projects/future-technologies/easy_contacts/1
