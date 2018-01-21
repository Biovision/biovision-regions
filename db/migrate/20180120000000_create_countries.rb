class CreateCountries < ActiveRecord::Migration[5.1]
  def up
    unless Country.table_exists?
      create_table :countries do |t|
        t.timestamps
        t.boolean :visible, default: true, null: false
        t.integer :priority, limit: 2, default: 1, null: false
        t.string :name, null: false
        t.string :short_name
        t.string :locative
        t.string :slug
      end

      Country.create(name: 'Российская Федерация', short_name: 'Россия', locative: 'в России', slug: 'russia')

      create_privileges
    end
  end

  def down
    if Country.table_exists?
      drop_table :countries
    end
  end

  def create_privileges
    PrivilegeGroup.create(slug: 'region_managers', name: 'Управляющие регионами')

    Privilege.create(slug: 'chief_region_manager', name: 'Главный управляющий регионамми')
    Privilege.create(
      parent: Privilege.find_by!(slug: 'chief_region_manager'),
      slug: 'region_manager',
      name: 'Управляющий регионом',
      regional: true
    )

    group = PrivilegeGroup.find_by!(slug: 'region_managers')
    group.add_privilege(Privilege.find_by(slug: 'chief_region_manager'))
    group.add_privilege(Privilege.find_by(slug: 'region_manager'))
  end
end
