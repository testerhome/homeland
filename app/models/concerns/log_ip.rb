module LogIp
  extend ActiveSupport::Concern

  def log_ip(ip, port = 80)
    ip_location = $Ip2Region.memory_search(ip)
    if ip_location.present?
      self.ip = ip
      self.ip_location = ip_location[:region]
    end
    self.remote_port = port
  end
end
