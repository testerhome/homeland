class AddPhotoIdToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :homeland_activities_events, :photo_url, :string
  end
end
