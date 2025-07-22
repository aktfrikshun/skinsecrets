class AddFeaturedToServices < ActiveRecord::Migration[8.0]
  def change
    add_column :services, :featured, :boolean
  end
end
