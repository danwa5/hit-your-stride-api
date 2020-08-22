class LocationSerializer
  include FastJsonapi::ObjectSerializer

  attributes :city, :state_province, :country
end
