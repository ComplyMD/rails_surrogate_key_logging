class CreateSurrogates < ActiveRecord::Migration[6.0]
  def change
    create_table :surrogates, id: false, options: 'ENGINE=InnoDB, CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' do |t|
      t.string :key, primary_key: true, null: false
      t.text :value, limit: 4294967295, null: false
      t.string :hashed_value, null: false

      t.datetime :updated_at, null: false
    end
    add_index :surrogates, :key, unique: true
    add_index :surrogates, :hashed_value, unique: true
  end
end
