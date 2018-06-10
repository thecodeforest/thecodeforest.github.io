import googlemaps
import pandas as pd
import pytz
import polyline

def extract_polyline(travel_dict):
    gmaps_polyline = travel_dict['overview_polyline']['points']
    polyline_df = pd.DataFrame(polyline.decode(gmaps_polyline))
    polyline_df.columns = ['lat', 'long']
    polyline_df['path_order'] = range(1, polyline_df.shape[0] + 1)
    return(polyline_df)


def find_path(route_df, gmaps_key, travel_mode):
	gmaps = googlemaps.Client(key=gmaps_key)
	route_df = pd.DataFrame(route_df)	
	row_count = 1 
	out_route_df = pd.DataFrame()
	for index, row in route_df.iterrows():
		print("Processing Stop {n} of {n_rows}".format(n = str(index),
													  n_rows = str(route_df.shape[0])
														))
		row_count += 1
		try:
			travel_data = gmaps.directions(origin = list(row[['start_lat', 
	                                                  'start_long']]),
	                               destination = list(row[['end_lat', 
	                                                       'end_long']]),
	                               mode = travel_mode
	                               )
			path_df = extract_polyline(travel_data[0])
			path_df['location_index'] = row['location_index']
			path_df['travel_time'] = travel_data[0]['legs'][0]['duration']['value']
			path_df['miles'] = travel_data[0]['legs'][0]['distance']['text']
			path_df['route_order'] = row['route_order']
			out_route_df = out_route_df.append(path_df)
		except Exception as e:
			print(e)
			out_route_df = out_route_df.append(['NA'] * 7)
	out_route_df = out_route_df.reset_index(drop = True)
	return(out_route_df)

 

 #        
	# return(out_route_df)

# def calc_route(route_df, gmaps_key, travel_mode, time_zone):
# 	gmaps = googlemaps.Client(key=gmaps_key)
# 	route_df = pd.DataFrame(route_df)	
# 	row_count = 1 
# 	out_route_df = pd.DataFrame()
#     for index, row in route_df.iterrows():
#         # print("Processing {n} path of {nrows}".format(n = str(row_count),
#         #                                         	  nrows = str(route_df.shape[0])
#         #                                         ))
# #        try:
# 		travel_data = gmaps.directions(origin = list(row[['start_lat', 
#                                                           'start_long']]),
#                                        destination = list(row[['end_lat', 
#                                                                'end_long']]),
#                                        mode = travel_mode,
#                                        departure_time = datetime.now(pytz.timezone(time_zone))
#                                        )
#         path_df = extract_polyline(travel_data[0])
#         path_df['location_index'] = row['location_index']
#         path_df['travel_time'] = travel_data[0]['legs'][0]['duration']['value']
#         path_df['miles'] = travel_data[0]['legs'][0]['distance']['text']
#         path_df['route_order'] = row['route_order']
#         out_route_df = out_route_df.append(path_df)
# #        except Exception as e:
#  #           print(e)
#         row_count += 1
#         if row_count > 5:
#         	break
#   	print(out_route_df)
#    # return(out_route_df)
