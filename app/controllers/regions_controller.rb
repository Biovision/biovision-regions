class RegionsController < AdminController
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /regions
  def create
    @entity = Region.new(creation_parameters)
    if @entity.save
      next_page = admin_region_path(@entity.id)
      respond_to do |format|
        format.html { redirect_to next_page }
        format.json { render json: { links: { self: next_page } } }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
    else
      render :new, status: :bad_request
    end
  end

  # get /regions/:id/edit
  def edit
  end

  # patch /regions/:id
  def update
    if @entity.update(entity_parameters)
      next_page = admin_region_path(@entity.id)
      respond_to do |format|
        format.html { redirect_to next_page, notice: t('regions.update.success') }
        format.json { render json: { links: { self: next_page } } }
        format.js { render js: "document.location.href = '#{next_page}'" }
      end
    else
      render :edit, status: :bad_request
    end
  end

  # delete /post_categories/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('regions.destroy.success')
    end
    redirect_to admin_regions_path
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
