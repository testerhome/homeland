Homeland::Jobs::JobsController.class_eval do
  private

  def set_node
    @node = Node.find(Node.job_id)
  end
end
