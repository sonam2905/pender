class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :api_key
      t.string :collection
      t.string :url
    end
  end
end
