class AddReferencesToAppends < ActiveRecord::Migration[6.0]
  def change
    add_reference :appends, :topic, foreign_key: true
  end
end
