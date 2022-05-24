class UserPhoneModule
  extend ActiveSupport::Concern



  def rebuild_phone_code(phone)
    Rails.cache.delete("phone_code_#{phone}")
    code = [100000, 999999].sample

    Rails.cache.fetch("phone_code_#{phone}", expires_in: 3.minute) do
      code
    end
  end

  def check_phone_code(phone, code)
    true_code = Rails.cache.read("phone_code_#{phone}")

    true_code == code && true_code.present?
  end

  def send_phone_code(phone, code)
    sendcloud_user = Setting.sendcloud_user
    sendcloud_key = Setting.sendcloud_key
    sendcloud_sms_template_id = Setting.sendcloud_sms_template_id

    params_str = {
      'phone' => phone,
      'smsUser' => sendcloud_user,
      'templateId' => sendcloud_sms_template_id,
      'vars' => {
        'code' => code
      }.to_json
    }.sort {| a, b| => a.to_s <=> b.to_s}.map { |item| "#{item[0]}=#{item[1]}" }.join('&')

    params_str = "#{sendcloud_key}&#{params_str}&#{send_phone_code}"
    Digest::MD5.new.update(param_str)
  end
end