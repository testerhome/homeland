module UserPhoneModule
  extend ActiveSupport::Concern

  class_methods do

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

    def send_phone_code(phone, code, name = 'testerhome用户')
      sendcloud_user = Setting.sendcloud_user
      
      sendcloud_sms_template_id = Setting.sendcloud_sms_template_id

      dict = {
        'phone' => phone,
        'smsUser' => sendcloud_user,
        'templateId' => sendcloud_sms_template_id,
        'vars' => {
          '%name%' => name,
          '%code%' => code
        }.to_json
      }
      sign = calc_send_cloud_sign(dict)
      dict['signature'] = sign

      response = RestClient.post "https://api.sendcloud.net/smsapi/send?", dict

      JSON.parse(response.to_s)['statusCode']
    
    end

    def calc_send_cloud_sign(dict)
      sendcloud_key = Setting.sendcloud_key
      params_str = dict.sort {| a, b| a.to_s <=> b.to_s}.map { |item| "#{item[0]}=#{item[1]}" }.join('&')
      params_str = "#{sendcloud_key}&#{params_str}&#{sendcloud_key}"
      Digest::MD5.new.update(params_str)
    end
  end

end

