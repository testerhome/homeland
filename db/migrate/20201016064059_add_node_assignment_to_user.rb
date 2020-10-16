class AddNodeAssignmentToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :node_assignment_ids, :integer, default: [], array: true
  end
end
