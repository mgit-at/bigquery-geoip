bigquery-geoip
==============

Scripts to load maxmind geoip DBs into bigquery

Implements the new binary based network matching as shown in
https://cloud.google.com/blog/products/data-analytics/geolocation-with-bigquery-de-identify-76-million-ip-addresses-in-20-seconds

```sql
# replace with your source of IP addresses
# here I'm using the same Wikipedia set from the previous article
WITH source_of_ip_addresses AS (
  SELECT REGEXP_REPLACE(contributor_ip, 'xxx', '0')  ip, COUNT(*) c
  FROM `publicdata.samples.wikipedia`
  WHERE contributor_ip IS NOT null  
  GROUP BY 1
)


SELECT city_name, SUM(c) c, ST_GeogPoint(AVG(longitude), AVG(latitude)) point
FROM (
  SELECT ip, city_name, c, latitude, longitude, geoname_id
  FROM (
    SELECT *, NET.SAFE_IP_FROM_STRING(ip) & NET.IP_NET_MASK(4, mask) network_bin
    FROM source_of_ip_addresses, UNNEST(GENERATE_ARRAY(9,32)) mask
    WHERE BYTE_LENGTH(NET.SAFE_IP_FROM_STRING(ip)) = 4
  )
  JOIN `YOUR_DATASET.geoip.city`  
  USING (network_bin, mask)
)
WHERE city_name  IS NOT null
GROUP BY city_name, geoname_id
ORDER BY c DESC
LIMIT 5000
```
