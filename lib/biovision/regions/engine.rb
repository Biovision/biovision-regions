module Biovision
  module Regions
    require 'biovision/base'
    require 'carrierwave'
    require 'carrierwave-bombshelter'
    require 'mini_magick'

    class Engine < ::Rails::Engine
      initializer 'biovision_regions.load_decorators' do
        require_dependency 'biovision/regions/decorators/controllers/admin/privileges_controller_decorator'
        require_dependency 'biovision/regions/decorators/models/user_decorator'
        require_dependency 'biovision/regions/decorators/models/user_privilege_decorator'
      end

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, :dir => 'spec/factories'
      end

      config.assets.precompile << %w(admin.scss)
      config.assets.precompile << %w(biovision/base/**/*)
    end
  end
end
