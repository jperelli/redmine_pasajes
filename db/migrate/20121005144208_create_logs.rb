class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.column :pid, :string
      t.column :uid, :integer
      t.column :revid, :integer
      t.column :date, :timestamp
      t.column :simulacion, :boolean
      t.column :success, :integer
    end
  end

  def self.down
    drop_table :logs
  end
end
