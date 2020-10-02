# 规避插件没有安装所导致的抱错
if defined?(Homeland::Jobs)
  Homeland::Jobs::JobsController.class_eval do
    private

    def set_node
      @node = Node.find(Node.job_id)
    end
  end
end
