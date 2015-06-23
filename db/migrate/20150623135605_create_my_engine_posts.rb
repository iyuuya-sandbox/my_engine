class CreateMyEnginePosts < ActiveRecord::Migration
  def change
    create_table :my_engine_posts do |t|
      t.string :title
      t.text :body

      t.timestamps null: false
    end
  end
end
