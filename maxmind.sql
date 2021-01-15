SELECT *
  , NET.IP_FROM_STRING(REGEXP_EXTRACT(network, r'(.*)/' )) network_bin
  , CAST(REGEXP_EXTRACT(network, r'/(.*)' ) AS INT64) mask
FROM geoip.city_blocks_ipv4
JOIN geoip.city_locations
USING(geoname_id)
