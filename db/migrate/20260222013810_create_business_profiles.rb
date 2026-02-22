class CreateBusinessProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :business_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :business_name, null: false
      t.string :ein
      t.string :business_type, default: "sole_proprietorship"
      t.integer :tax_year, null: false

      t.timestamps
    end

    add_index :business_profiles, [:user_id, :tax_year], unique: true
  end
end
