class Region < ApplicationRecord
  include Toggleable

  SLUG_PATTERN   = /\A[a-z0-9](?:[a-z0-9\-]{0,61}[a-z0-9])?\z/
  PER_PAGE       = 20
  NAME_LIMIT     = 70
  SLUG_LIMIT     = 63
  PRIORITY_RANGE = (1..32767)

  toggleable :visible

  belongs_to :country, optional: true, counter_cache: true
  belongs_to :parent, class_name: Region.to_s, optional: true, touch: true
  has_many :child_regions, class_name: Region.to_s, foreign_key: :parent_id
  has_many :users, dependent: :nullify

  mount_uploader :image, RegionImageUploader
  mount_uploader :header_image, HeaderImageUploader

  before_validation { self.slug = slug.to_s.downcase.strip }
  before_validation :normalize_priority
  before_save { self.children_cache.uniq! }
  before_save :generate_long_slug
  after_save { parent.cache_children! unless parent.nil? }
  after_create :cache_parents!

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug, scope: [:parent_id]
  validates_length_of :name, maximum: NAME_LIMIT
  validates_length_of :slug, maximum: SLUG_LIMIT
  validates_format_of :slug, with: SLUG_PATTERN

  scope :ordered_by_priority, -> { order 'priority asc, name asc' }
  scope :ordered_by_slug, -> { order('slug asc') }
  scope :ordered_by_name, -> { order('name asc') }
  scope :visible, -> { where(visible: true) }
  scope :for_tree, ->(country_id = nil, parent_id = nil) { where(country_id: country_id, parent_id: parent_id).ordered_by_priority }
  scope :siblings, ->(item) { where(country_id: item.country_id, parent_id: item.parent_id) }

  # @param [Integer] page
  def self.page_for_administration(page = 1)
    ordered_by_name.page(page).per(PER_PAGE)
  end

  def self.entity_parameters
    %i(name short_name locative slug visible image header_image latitude longitude)
  end

  def self.creation_parameters
    entity_parameters + %i(country_id parent_id)
  end

  # @param [User] user
  def editable_by?(user)
    chief   = UserPrivilege.user_has_privilege?(user, :chief_region_manager)
    manager = UserPrivilege.user_has_privilege?(user, :region_manager, self)
    chief || manager
  end

  def parents
    return [] if parents_cache.blank?
    Region.where(id: parent_ids).order('id asc')
  end

  def parent_ids
    parents_cache.split(',').compact
  end

  # @return [Array<Integer>]
  def branch_ids
    parents_cache.split(',').map(&:to_i).reject { |i| i < 1 }.uniq + [id]
  end

  # @return [Array<Integer>]
  def subbranch_ids
    [id] + children_cache
  end

  def depth
    parent_ids.count
  end

  def long_name
    return name if parents.blank?
    "#{parents.map(&:name).join('/')}/#{name}"
  end

  def branch_name
    return short_name if parents.blank?
    "#{parents.map(&:short_name).join('/')}/#{short_name}"
  end

  def cache_parents!
    return if parent.nil?
    self.parents_cache = "#{parent.parents_cache},#{parent_id}".gsub(/\A,/, '')
    save!
  end

  def cache_children!
    child_regions.order('id asc').each do |child|
      self.children_cache += [child.id] + child.children_cache
    end
    save!
    parent.cache_children! unless parent.nil?
  end

  # @param [Integer] delta
  def change_priority(delta)
    new_priority = priority + delta
    criteria     = { country_id: county_id, parent_id: parent_id, priority: new_priority }
    adjacent     = self.class.find_by(criteria)
    if adjacent.is_a?(self.class) && (adjacent.id != id)
      adjacent.update!(priority: priority)
    end
    self.update(priority: new_priority)

    self.class.for_tree(country_id, parent_id).map { |e| [e.id, e.priority] }.to_h
  end

  private

  def set_next_priority
    if id.nil? && priority == 1
      self.priority = self.class.siblings(self).maximum(:priority).to_i + 1
    end
  end

  def normalize_priority
    self.priority = PRIORITY_RANGE.first if priority < PRIORITY_RANGE.first
    self.priority = PRIORITY_RANGE.last if priority > PRIORITY_RANGE.last
  end

  def generate_long_slug
    if parents_cache.blank?
      self.long_slug = slug
    else
      slugs          = Region.where(id: parent_ids).order('id asc').pluck(:slug) + [slug]
      self.long_slug = slugs.join('-')
    end
  end
end
