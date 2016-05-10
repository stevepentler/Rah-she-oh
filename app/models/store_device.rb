module StoreDevice
  def save_devices(devices)
    devices.each do |single_device|
      device = Device.find_or_create_by(device_id: single_device)
      # device.user_id = user_id
      device.save
    end
  end

  def save_zones(zones, device_id)
    device = Device.find_by(device_id: device_id)
    zones.each do |single_zone|
      zone = device.zones.find_or_create_by(zone_id: single_zone["id"])
      zone.device_id = device.id
      zone.save
    end
  end
end