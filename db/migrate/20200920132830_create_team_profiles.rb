class CreateTeamProfiles < ActiveRecord::Migration[6.0]
  def change
    create_table :team_profiles do |t|
      t.integer  :team_id, null: false
      t.text :apply_message
      t.boolean :show_reward, default: false
      t.timestamps
    end
  end
end
