class Ip2Region
  INDEX_BLOCK_LENGTH = 12
  TOTAL_HEADER_LENGTH = 8192
  attr_accessor :f, :headerSip, :headerPtr, :headerLen, :indexSPtr, :indexLPtr, :indexCount, :dbBinStr

  def initialize(dbfile = Rails.root.join("lib", "ip2region.db"))
    init_database(dbfile)
    true
  end

  def init_database(dbfile = "ip2region.db")
    @dbBinStr = File.open(dbfile, "rb").read

    @indexSPtr = get_long(@dbBinStr, 0)
    @indexLPtr = get_long(@dbBinStr, 4)
    @indexCount = ((indexLPtr - indexSPtr) / INDEX_BLOCK_LENGTH).to_i + 1
    # puts "#{@indexSPtr} #{@indexLPtr} #{@indexCount}"
  end

  def memory_search(ip)
    ip = ip2long(ip)

    l, h, dataPtr = 0, indexCount, 0
    # print(l,h,dataPtr)
    while l <= h
      m = (l + h) >> 1
      p = m * INDEX_BLOCK_LENGTH + indexSPtr
      # puts "m = #{m}, p = #{p}"
      sip = get_long(@dbBinStr, p)
      # puts "sip =  #{sip}"

      if ip < sip
        h = m - 1
      else
        eip = get_long(@dbBinStr, p + 4)
        if ip > eip
          l = m + 1
        else
          dataPtr = get_long(@dbBinStr, p + 8)
          break
        end
      end
    end

    if dataPtr == 0
      return nil
    end

    return_data(dataPtr)
  end

  def return_data(dataPtr)
    dataLen = (dataPtr >> 24) & 0xFF
    dataPtr = dataPtr & 0x00FFFFFF
    data = @dbBinStr[dataPtr, dataLen]
    # @dbBinStr.seek(dataPtr)
    # data = @dbBinStr.read(dataLen)

    return {
             :city_id => get_long(data, 0),
             :region => data[4..-1].force_encoding("utf-8"),
           }
  end

  def get_long(b, offset)
    if (b[offset..offset + 3] || []).length == 4
      # puts "unpack = #{b[offset..offset+3].unpack('I')}"
      return b[offset..offset + 3].unpack("I")[0].to_i
    end
    0
  end

  def ip2long(ip)
    ip.split(".").inject(0) { |s, x| s * 256 + x.to_i }
  end
end

$Ip2Region = Ip2Region.new
