class AddOAuthFieldsToUser < ActiveRecord::Migration
  def up
    add_column :users, :oauth_token, :text
    add_column :users, :oauth_expires_at, :datetime
  end

  def down
    remove_column :users, :oauth_token
    remove_column :users, :oauth_expires_at
  end
end
