module Utils
  def self.storeDataInShoStore(data)
    p "#{Rails.configuration.qrurl}"
    res = HTTPClient.new.post("#{Rails.configuration.qrurl}",
        data.to_json,
        {"Content-Type" => "application/json"})
    p "*************************************************\n\n"
    p "Result of store call #{res.status}, #{res.content}, #{JSON.parse(res.content)["result"]}"
    p "*************************************************\n\n"

    sess_id = JSON.parse(res.content)["id"]
    return "#{Rails.configuration.qrurl}/#{sess_id}/qr"
  end
end
