import pandas as pd
import googlemaps

def geocode_address(address_dict, gmaps_key):
	gmaps = googlemaps.Client(key=gmaps_key)
	geocoded_addresses = []
	for name, address in address_dict.items():
		print("Geocoding Address {tmp_address}".format(tmp_address = address))
		try:
			geocode_result = gmaps.geocode(address)
			lat_long = geocode_result[0]['geometry']['location'].values()
	 		lat_long.extend([address, name])
	 		geocoded_addresses.append(lat_long)
	 	except Exception as e:
	 		print(e)
	 		geocoded_addresses.append(['NA', 'NA', address, name])

	geocode_address_df = pd.DataFrame(geocoded_addresses)
	geocode_address_df.columns = ['lat',
								  'long',
								  'address',
								  'name']
	return(geocode_address_df)


