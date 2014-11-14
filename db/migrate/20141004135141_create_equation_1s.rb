class CreateEquation1s < ActiveRecord::Migration
  def change
    create_table :equation_1s do |t|
      t.integer :ua
      t.integer :ub
      t.integer :c

      t.timestamps
    end
  end
end
