class Admin::RegionsController < AdminController
  include ToggleableEntity
  include LockableEntity
  include EntityPriority

  before_action :set_entity, except: [:index]

  # get /admin/regions
  def index
    @collection = Region.for_tree
  end

  # get /admin/regions/:id
  def show
  end

  private

  def restrict_access
    require_privilege_group :region_managers
  end

  def set_entity
    @entity = Region.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find region #{params[:id]}")
    end
  end
end
