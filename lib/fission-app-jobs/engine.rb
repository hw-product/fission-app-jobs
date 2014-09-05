require 'fission-app-multiuser'

module FissionApp
  module Jobs
    class Engine < ::Rails::Engine

      config.to_prepare do |config|
        require 'fission-data/init'
        product = Fission::Data::Models::Product.find_or_create(:name => 'Jobs')
        feature = Fission::Data::Models::ProductFeature.find_or_create(
          :name => 'jobs_information',
          :product_id => product.id
        )
        unless(feature.permissions_dataset.where(:name => 'jobs_info_access').count > 0)
          feature.add_permission(
            :name => 'jobs_info_access',
            :pattern => '/jobs(/show.*)'
          )
        end
      end

    end
  end
end
