from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from kd1 import fetch_accommodation_data, insert, searchAccommodations
import os
import cx_Oracle
from dotenv import load_dotenv
import new_trie
import kd1

load_dotenv()

basedir = os.path.abspath(os.path.dirname(__file__))
template_dir = os.path.join(basedir, 'templates')

app = Flask(__name__, template_folder = template_dir)
app.secret_key = os.getenv('FLASK_SECRET_KEY')


# Set secret key from environment variable
app.secret_key = os.getenv('FLASK_SECRET_KEY')

# Oracle client path from environment variable
oracle_client_path = os.getenv('ORACLE_CLIENT_PATH')

# Initialize Oracle client
cx_Oracle.init_oracle_client(lib_dir=oracle_client_path)

# Connection parameters from environment variables
username = os.getenv('ORACLE_USERNAME')
password = os.getenv('ORACLE_PASSWORD')
dsn = os.getenv('ORACLE_DSN')

# Construct connection string
connection_string = f'{username}/{password}@{dsn}'

connection = cx_Oracle.connect(connection_string)
cursor = connection.cursor()
kd_tree_root = None
def initialize_kd_tree():
    global kd_tree_root
    accommodation_df = kd1.fetch_accommodation_data(cursor)

    for index, row in accommodation_df.iterrows():
        point = [row['distance']]
        accommodation = row.to_dict()
        kd_tree_root = kd1.insert(kd_tree_root, point, accommodation)

initialize_kd_tree()

# Flask routes
@app.route('/')
def home():
    print("Home route accessed")
    session.clear()
    return render_template('home_page.html')

@app.route('/location',methods=['GET','POST'])
def location():
    print("Location route accessed")
    return render_template('location.html')

@app.route('/uni_amen',methods=['GET','POST'])
def uni_amen():
    print("Uni_amen route accessed")
    return render_template('uni_amen.html')

@app.route('/move_in_dur_budget',methods=['GET','POST'])
def move_in_dur_budget():
    print("Move_in_dur_budget route accessed")
    return render_template('move-in_dur_budget.html')

@app.route('/Details_for_contact')
def Details_for_contact():
    print("Details_for_contact route accessed")
    return render_template('Details_for_contact.html')

@app.route('/login', methods=['POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('loginEmail')
        password = request.form.get('loginPassword')
        print(email,password)
        try:
            # Call PL/SQL procedure to check login credentials
            login_success = cursor.var(cx_Oracle.NUMBER)
            cursor.callproc("check_login", [email, password, login_success])

            # Access the output parameter value
            login_status = login_success.getvalue()
            print(login_status)

            # Redirect to the next page if login is successful
            if login_status == 1:
                session['user_id'] = email  # Store user email in session
                return jsonify({"login_status": 1})
                #return redirect(url_for('possible_accom'))
                #return jsonify({"login_status": login_status})
                
            else:
                return jsonify({"login_status": login_status})
        except Exception as e:
            # Handle exceptions appropriately
            return jsonify({"error": str(e)})
    
@app.route('/signup', methods=['POST'])
def signup():
    try:
        name = request.form.get('name')
        contact = request.form.get('phone')
        email = request.form.get('email')
        password = request.form.get('password')
        college_name = request.form.get('college')
        
        # Call the stored procedure to insert user data into the users table
        cursor.callproc("register_user", [name, contact, email, password, college_name])
        
        # Commit the transaction
        connection.commit()
        session['user_id'] = email

        # Redirect to the next page after successful signup
        return jsonify({"signup_status": 1})
        
        
    except Exception as e:
        # Handle exceptions appropriately
        return jsonify({"error": str(e)})

data=[]
@app.route('/accommodation')
def possible_accom():
    cursor.execute("SELECT name, image FROM Accommodation")
    db_data = cursor.fetchall()
    images = {row[0]: row[1] for row in db_data}

    # Merge image URLs with the sample data
    for entry in data:
        entry['image'] = images.get(entry['name'], 'default.jpg')
    return render_template('accommodation.html', data=data)

'''def link(matched_accommodations):
    return matched_accommodations'''

@app.route('/<item_name>.html')
def item_page(item_name):
    return render_template(f'{item_name}.html')
    '''
    if 'user_id' not in session:
        #return redirect(url_for('home'))
    return render_template('accommodation.html')'''


def find_universities_by_location(location):
    try:
        # Call the PL/SQL procedure to find colleges at the specified location
        cursor.callproc("find_colleges_at_location", [location, cursor.var(cx_Oracle.CURSOR)])
        result_cursor = cursor.var(cx_Oracle.CURSOR)

        cursor.execute("BEGIN find_colleges_at_location(:location, :colleges); END;",
                       location=location, colleges=result_cursor)

        # Fetch all rows from the result cursor
        result = result_cursor.getvalue()

        # Extract the names of colleges from the result
        universities = [row[0] for row in result]

        return universities
    except cx_Oracle.Error as error:
        # Handle the error appropriately
        print("Error fetching universities:", error)
        return []

@app.route('/get_university_suggestions', methods=['POST'])
def get_university_suggestions():
    try:
        data = request.json
        location = data.get('location')

        # Find universities at the specified location
        universities = find_universities_by_location(location)
        print(universities)

        # Construct Trie and insert universities into it
        trie = new_trie.Trie()
        for university in universities:
            trie.insert(university)

        # Get suggestions based on input pattern matching
        search_query = data.get('search_query', '').lower()
        suggestions = trie.autocomplete(search_query)
        print(suggestions)

        # Construct HTML content for suggestions
        suggestion_html = ''
        for suggestion in suggestions:
            suggestion_html += f'<div class="suggestion" onclick="selectUniversity(\'{suggestion}\')">{suggestion}</div>'
        print(suggestion_html)

        # Return JSON response with suggestion HTML
        return jsonify({'suggestion_html': suggestion_html})

    except Exception as e:
        print("Error getting university suggestions:", e)
        return jsonify({"error": str(e)})

all_data = {
    'location':None,
    'college_name':None,
    'amenities': set(),
    'moveInDate': None,
    'budget': None,
    'duration': None
}


# Function to clear search results
def clear_search_results():
    global data
    data = []

def build_kd_tree(data_dict):
    global kd_tree_root
    budget = data_dict['budget']
    lower_budget = None
    upper_budget = None
    
    # Check if budget is a range
    if "_" in budget:
        budget_parts = budget.split("_")
        try:
            if "more" in budget.lower() :
                lower_budget = float(budget_parts[2])
                upper_budget = float(50000)
            elif 'under' in budget.lower():
                lower_budget = 0.0
                upper_budget = float(500)
            else:
                lower_budget = float(budget_parts[0])
                upper_budget = float(budget_parts[1])
        
        # Try to parse the lower and upper budget values
        
            
        except ValueError as e:
            
                print(f"Error parsing budget range: {e}")
                return jsonify({"error": "Invalid budget range values"}), 400
    amenities = data_dict['amenities']
    location = data_dict['location']

    print("From kdtree",budget)
    print("From kdtree",amenities)
    print("From kdtree",location)

    # Validate budget input
    if not budget:
        return jsonify({"error": "Budget is required"}), 400
    '''try:
        budget = float(budget)
    except ValueError:
        return jsonify({"error": "Invalid budget value"}), 400'''
    matched_accommodations = kd1.searchAccommodations(kd_tree_root, lower_budget, upper_budget, amenities, location)
    

    # Reset global data to avoid duplicates
    global data
    data = []

    for accommodation in matched_accommodations:
        aid = accommodation['aid']
        aname = accommodation['name']
        data.append({"aid": accommodation['aid'], "name": accommodation['name']})
        print(f"aid: {aid}, name: {aname}")

    return matched_accommodations


@app.route('/possible_accomodations', methods=['POST'])
def possible_accomodations():
    
    if request.method == 'POST':
        data = request.json
        location = data.get('location', '')
        college_name = data.get('search_query', '')
        amenities = data.get('amenities', [])
        moveInDate = data.get('moveInDate', '')
        
        budget = data.get('budget', '')
        duration = data.get('duration', '')
        
        if location:
            all_data['location'] = location
        if college_name:
            all_data['college_name'] = college_name
        if amenities:
            all_data['amenities'].update(amenities)
        if moveInDate:
            all_data['moveInDate'] = moveInDate
        if budget:
            all_data['budget'] = budget
        if duration:
            all_data['duration'] = duration

        if all(value is not None for key, value in all_data.items() if key != 'amenities'):
            print("All Data:", all_data)
            return build_kd_tree(all_data)
        else:
            return jsonify({"error": "Incomplete data"}), 400
       
@app.route('/accommodation/<int:accommodation_id>')
def accommodation(accommodation_id):
    cursor.execute("SELECT aid, name, address, price, amenities, distance FROM Accommodation WHERE aid = :aid", {'aid': accommodation_id})
    accommodation = cursor.fetchone()
    if not accommodation:
        return "Accommodation not found", 404

    accommodation_dict = {
        'aid': accommodation[0],
        'name': accommodation[1],
        'address': accommodation[2],
        'price': accommodation[3],
        'amenities': accommodation[4],
        'distance': accommodation[5]
    }

    return render_template('accommodation.html', accommodation=accommodation_dict)

if __name__ == '__main__':
    app.run(debug=True)
