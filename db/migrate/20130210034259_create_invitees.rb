class CreateInvitees < ActiveRecord::Migration
  def change
    create_table :invitees do |t|
      t.integer :invitation_id, :null => false
      t.boolean :guest, :default => 0
      t.string :first_name
      t.string :last_name
      t.integer :attending, :limit => 1
      t.integer :position, :limit => 1

      t.timestamps
    end

    add_foreign_key :invitees, :invitations, :dependent => :delete
  end
end
