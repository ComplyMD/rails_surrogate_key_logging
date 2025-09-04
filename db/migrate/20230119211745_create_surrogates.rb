class CreateSurrogates < ActiveRecord::Migration[6.0]
  def change
    # MySQL/MariaDB allow passing engine / charset options. SQLite & Postgres will choke
    # on the raw string, so only supply options when supported.
    table_options = if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
                      'ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
                    end

    create_table :surrogates, id: false, options: table_options do |t|
      # String (VARCHAR/TEXT) primary key is supported across adapters, but extremely large
      # text limits are unnecessary for SQLite. Let AR pick the right underlying type.
      t.string :key, primary_key: true, null: false
      t.text :value, null: false
      t.string :hashed_value, null: false
      t.datetime :updated_at, null: false
    end

    # Explicit unique indexes (SQLite automatically indexes the PK, but this keeps parity)
    add_index :surrogates, :key, unique: true
    add_index :surrogates, :hashed_value, unique: true
  end
end
