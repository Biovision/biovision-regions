class RegionsController < ApplicationController
  before_action :restrict_access, except: [:index, :show, :children]
  before_action :set_entity, except: [:index, :new, :create]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  layout 'admin', except: [:index, :show, :children]

  # get /regions
  def index
    @collection = Region.visible.for_tree
  end

  # post /regions
  def create
    @entity = Region.new(creation_parameters)
    if @entity.save
      form_processed_ok(admin_region_path(@entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /regions/:id
  def show
    unless @entity.visible
      handle_http_404('Region is not visible')
    end
  end

  # get /regions/:id/edit
  def edit
  end

  # patch /regions/:id
  def update
    if @entity.update(entity_parameters)
      form_processed_ok(admin_region_path(@entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /regions/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('regions.destroy.success')
    end
    redirect_to admin_regions_path
  end

  # get /regions/:id/children
  def children
    @collection = Region.visible.for_tree(@entity.country_id, @entity.id)

    render :index
  end

  protected

  def restrict_access
    require_privilege_group :region_managers
  end

  def set_entity
    @entity = Region.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find region')
    end
  end

  def restrict_editing
    if @entity.locked? || !@entity.editable_by?(current_user)
      redirect_to admin_region_path(@entity.id), alert: t('regions.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:region).permit(Region.entity_parameters)
  end

  def creation_parameters
    params.require(:region).permit(Region.creation_parameters)
  end
end
