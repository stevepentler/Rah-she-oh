class RachioService
  include StoreDevice
  attr_reader :client,
              :user_id

  def initialize
    @client = Faraday.new("https://api.rach.io/1/public/") do |faraday|
      faraday.headers = rachio_headers
      faraday.adapter Faraday.default_adapter
    end
  end

  def retrieve_user_id
    response = client.get("person/info")
    @user_id = parse_body(response)["id"]
  end

  def retrieve_user_info
    id = retrieve_user_id
    response = client.get("person/#{id}")
    info = parse_body(response)
  end

  def retrieve_devices
    devices = retrieve_user_info["devices"]
    save_devices(devices, user_id)
    return devices
  end

  def retrieve_device_zones(id=nil)
    device_id = id ||= retrieve_devices.first["id"]
    response = client.get("device/#{device_id}")
    zones = parse_body(response)["zones"]
    save_zones(zones, device_id)
    return zones
  end

  def store_data
    retrieve_user_id
    retrieve_devices
    retrieve_device_zones
  end

  def start_zone(params)
    zone_id = params["zoneId"]
    zone_duration = params["zoneDuration"].to_i
    response = client.put("zone/start", format_data(zone_id, zone_duration))
  end

  def format_data(zone_id, zone_duration)
    data = "{ \"id\" : \"#{zone_id}\", \"duration\" : #{zone_duration} }"
  end
  private

  def rachio_headers
    {"Authorization" => "Bearer #{ENV['ACCESS_TOKEN']}",
     "Content-Type" => "application/json" }
  end

  def parse_body(response)
    JSON.parse(response.body)
  end
end