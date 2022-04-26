class AddResumeFeature < ActiveRecord::Migration[6.1]
  def change
    # 增加招聘信息扩展表
    create_table :hire_topic_ext do |t|
      t.references :topics, :null => false
      t.string :email_url, :null => false
      t.timestamps
    end

    # 帖子增加招聘扩展信息的关联关系
    add_reference :topics, :hire_topic_ext

    # 增加简历表，并关联用户信息
    create_table :resumes do |t|
      t.string :resume_name # 给用户记录个别名，方便记忆自己这个简历是干嘛的
      t.string :resume_url, :null => false # 简历都是以附件形式存在，所以只需要记录附件路径即可
      t.references :users, :null => false
      t.timestamps
    end

    # 用户表增加是否授权简历字段
    add_column :users, :resume_authorization, :boolean, default: false

    # 增加投递记录表，记录用户投递动作，便于查询已投递信息
    create_table :send_resume_records do |t|
      t.references :users, :null => false
      t.references :topics, :null => false
      t.references :resumes, :null => false
      t.string :result # 记录投递结果，如果失败（如邮箱地址不存在）会记录相应的失败信息
      t.timestamps
    end

  end
end
