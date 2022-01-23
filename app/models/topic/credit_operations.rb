# frozen_string_literal: true

class Topic
  module CreditOperations
    extend ActiveSupport::Concern

    # 判断是否是技术节点
    def tech_node?
      # TODO 从配置文件中读出是否包含节点
      Setting.tech_node_ids.include? self.node_id
    end

    def reach_reply_limit?(reply_user)
      limit = Setting.topic_reply_credit_limit

      CreditRecord.where(model_id: self.id,
        model_type: "Topic",
        category: "topic_reply",
        operator: reply_user.id).sum(:num) >= limit
    end
  end
end
