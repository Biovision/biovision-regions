class CreateRegions < ActiveRecord::Migration[5.1]
  def up
    unless Region.table_exists?
      create_table :regions do |t|
        t.timestamps
        t.references :country, foreign_key: { on_update: :cascade, on_delete: :cascade }
        t.integer :parent_id
        t.integer :users_count, default: 0, null: false
        t.boolean :visible, default: true, null: false
        t.boolean :locked, default: false, null: false
        t.float :latitude
        t.float :longitude
        t.string :slug, null: false
        t.string :long_slug, null: false, index: true
        t.string :name, null: false
        t.string :short_name
        t.string :locative
        t.string :image
        t.string :header_image
        t.string :image_url
        t.text :map_geometry
        t.text :svg_geometry
        t.string :parents_cache, default: '', null: false
        t.integer :children_cache, array: true, default: [], null: false
      end

      add_foreign_key :regions, :regions, column: :parent_id, on_update: :cascade, on_delete: :cascade
    end
  end

  def down
    if Region.table_exists?
      drop_table :regions
    end
  end
end
