class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :heading
      t.text :body
      t.decimal :price
      t.string :external_url 
      t.string :neighborhood
      t.string :timestamp

      t.timestamps
    end
  end
end
