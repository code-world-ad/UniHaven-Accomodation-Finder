import pandas as pd
import numpy as np

# A class to represent a node in the KD tree
class Node:
    def __init__(self, point, accommodation):
        self.point = point
        self.accommodation = accommodation
        self.left = None
        self.right = None

# Function to create a new KD tree node
def newNode(point, accommodation):
    return Node(point, accommodation)

# Recursive function to insert a new point into the KD tree
def insertRec(root, point, accommodation, depth):
    if root is None:
        return newNode(point, accommodation)
    
    cd = depth % 1  # Single dimension (distance)

    if point[cd] < root.point[cd]:
        root.left = insertRec(root.left, point, accommodation, depth + 1)
    else:
        root.right = insertRec(root.right, point, accommodation, depth + 1)

    return root

# Function to insert a new point with the given point into the KD tree
def insert(root, point, accommodation):
    return insertRec(root, point, accommodation, 0)

# Function to search for accommodations within budget and with desired amenities
def searchAccommodations(root, lower_budget, upper_budget, amenities, location):
    results = []
    searchAccommodationsRec(root, lower_budget, upper_budget, amenities, location, results)
    return results

# Recursive function to search for accommodations within budget and with desired amenities
def searchAccommodationsRec(root, lower_budget, upper_budget, amenities, location, results):
    if root is None:
        return
    accommodation_location = root.accommodation['address'].split(',')[-1].strip()
    if lower_budget <= root.accommodation['price'] <= upper_budget and accommodation_location == location:
        if not amenities or all(amenity in root.accommodation['amenities'] for amenity in amenities):
            results.append(root.accommodation)
    searchAccommodationsRec(root.left, lower_budget, upper_budget, amenities, location, results)
    searchAccommodationsRec(root.right, lower_budget, upper_budget, amenities, location, results)

# Function to fetch accommodation data from database
def fetch_accommodation_data(cursor):
    cursor.execute("SELECT a.aid, a.name, a.address, a.price, a.amenities, d.distance FROM Accommodation a, Distance d WHERE a.aid = d.accommodation_id")
    data = cursor.fetchall()
    columns = ['aid', 'name', 'address', 'price', 'amenities', 'distance']
    return pd.DataFrame(data, columns=columns)

# Function to clear search results
def clear_search_results():
    global search_results
    search_results = set()

# Initialize search results
search_results = set()

# Example usage:
# cursor = <database cursor>
# accommodation_data = fetch_accommodation_data(cursor)
# root = None
# for index, row in accommodation_data.iterrows():
#     point = [row['distance']]
#     accommodation = row.to_dict()
#     root = insert(root, point, accommodation)

# To search:
# clear_search_results()
# results = searchAccommodations(root, lower_budget, upper_budget, amenities, location)

# Implement the back button click handler to call `clear_search_results()`
