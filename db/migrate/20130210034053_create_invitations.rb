class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :code
      t.string :name
      t.string :email
      t.text :address
      t.text :requests
      t.text :notes
      t.datetime :sent_at
      t.datetime :opened_at
      t.datetime :last_viewed_at
      t.datetime :phoned_in_at
      t.datetime :responded_at

      t.timestamps
    end
  end
end