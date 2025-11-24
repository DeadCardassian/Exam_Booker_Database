from flask import Flask, session, render_template, request, redirect, url_for, jsonify, flash
from datetime import datetime
import mysql.connector
import bcrypt
import csv



app = Flask(__name__)

app.secret_key = "my_se_key"  # allow flash

# connect db
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",        
        password="",         
        database="exam_booker"    
    )

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/about')
def about():
    return render_template('about_us.html')

@app.route('/view_sponsors')
def view_sponsors():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        cursor.execute("""
            SELECT 
                DISTINCT(sponsor_name)
            FROM sponsor_exam_details
            ORDER BY sponsor_name ASC
        """)

        sponsors = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template('view_sponsors.html', sponsors=sponsors)

    except:
        return render_template('view_sponsors.html', sponsors="No Sponsors to View")



@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':

        email = request.form.get('username')     # frontend input
        password = request.form.get('password')
        user_type = request.form.get('user_type')  # TT / TC / ES
        print("************ USER TYPE *********** ")
        print(user_type)
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
    

        # ---- 1) fetch user from DB ----
        cursor.execute("""
            SELECT user_id, user_email, user_password_h, user_type
            FROM user
            WHERE user_email = %s
        """, (email,))
        user = cursor.fetchone()
        user_id = user["user_id"]
        print("************ USER ID *********** ")
        print(user_id)
        cursor.close()
        conn.close()

        # ---- 2) user not found ----
        if not user:
            flash("User not found.", "error")
            return render_template('login.html')

        # ---- 3) user_type mismatch ----
        if user['user_type'] != user_type:
            flash("User type does not match this account.", "error")
            return render_template('login.html')

        # ---- 4) check password ----
        stored_hash = user['user_password_h'].encode('utf-8')

        if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
            # flash("Login successful!", "success")
            if user_type == "TT":
                session["user_id"] = user_id
                return redirect(url_for("my_registrations", user_id=user_id))
            elif user_type == "TC":
                session["user_id"] = user_id
                return redirect(url_for("view_availabilities", user_id=user_id))
            else:
                session["user_id"] = user_id
                return redirect(url_for("sponsor_contract", user_id=user_id))
               
        else:
            flash("Incorrect password.", "error")
            return render_template('login.html')

    return render_template('login.html')

@app.route('/log_out')
def log_out():
    session.clear()
    user_id = session.get("user_id")
    print("*********LOGGED OUT********")
    print(user_id)

    return redirect(url_for("home"))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        email = request.form.get('username')     # user email
        password = request.form.get('password')
        user_type = request.form.get('user_type')  # TT / TC / ES

        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # ---- 1) Check if any account exists with this email (best practice) ----
        cursor.execute("""
            SELECT user_email FROM user WHERE user_email = %s
        """, (email,))
        existing = cursor.fetchone()

        if existing:
            cursor.close()
            conn.close()
            flash("This email is already registered.", "error")
            return render_template('registration_page.html')

        # ---- 2) bcrypt hash ----
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        hashed_pw = hashed_pw.decode('utf-8')

        # ---- 3) Insert new user ----
        cursor.execute("""
            INSERT INTO user (user_email, user_password_h, user_type)
            VALUES (%s, %s, %s)
        """, (email, hashed_pw, user_type))

        user_id = cursor.lastrowid
        conn.commit()
        cursor.close()
        conn.close()

        flash("Registration successful!", "success")

        # TODO: Redirect based on user type, let the user fill more info regarding their user type
        # TODO: This function cannot insert username and passwords. They need to be filled in on the redirect page
        '''
        if user_type == "TT":
            return redirect(url_for("register_test_taker_info", user_id=user_id))
        elif user_type == "TC":
            return redirect(url_for("register_test_center_info", user_id=user_id))
        else:
            return redirect(url_for("register_exam_sponsor_info", user_id=user_id))
        '''

        return render_template('login.html')


    return render_template('registration_page.html')



@app.route('/availabilities/upload', methods=['GET', 'POST'])
def upload_availabilities():
    if request.method == 'POST':
        # Ensure file exists
        if 'csv_file' not in request.files:
            flash("No file uploaded.", "error")
            return redirect(url_for('upload_availabilities'))

        file = request.files['csv_file']

        if file.filename == '':
            flash("Empty file name.", "error")
            return redirect(url_for('upload_availabilities'))

        # Read CSV
        try:
            conn = get_connection()
            cursor = conn.cursor()
            user_id = session.get("user_id")
            cursor.execute("""
                    SELECT test_center_id FROM test_center
                    WHERE user_id = %s
                """, (user_id,))
            test_center_id = cursor.fetchone()
            test_center_id = test_center_id[0]

            csv_reader = csv.reader(file.stream.read().decode('utf-8').splitlines())
            next(csv_reader)  # skip header

            count = 0
            for row in csv_reader:
                str_date, str_start, str_end, duration, str_capacity = row
    
                date_of_availability = datetime.strptime(str_date, "%m/%d/%y").strftime("%Y-%m-%d")
                start_time_slot = datetime.strptime(str_start, "%H:%M").strftime("%H:%M:%S")
                end_time_slot   = datetime.strptime(str_end, "%H:%M").strftime("%H:%M:%S")
                
                print("***********DATA INSERT*************")
                print(f"{test_center_id}, {date_of_availability}, {start_time_slot}, {end_time_slot}, {int(str_capacity)}")

                cursor.execute("""
                    INSERT INTO test_center_availability 
                    (test_center_id, date_of_availability, start_time_slot, end_time_slot, seat_capacity)
                    VALUES (%s, %s, %s, %s, %s)
                """, (test_center_id, date_of_availability, start_time_slot, end_time_slot, int(str_capacity)))

                count += 1

            conn.commit()
            cursor.close()
            conn.close()

            flash(f"Uploaded {count} availability slots.", "success")

        except Exception as e:
            flash(f"Upload failed: {e}", "error")

        return redirect(url_for('upload_availabilities'))

    return render_template('upload_availabilities.html')


@app.route('/view_availabilities')
def view_availabilities():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        user_id = session.get("user_id")
        cursor.execute("""
                SELECT test_center_id FROM test_center
                WHERE user_id = %s
            """, (user_id,))
        test_center_id = cursor.fetchone()
        test_center_id = test_center_id["test_center_id"]

        cursor.execute("""
            SELECT 
                availability_slot_id,
                date_of_availability,
                start_time_slot,
                end_time_slot,
                seat_capacity,
                scheduled_count
            FROM test_centers_with_availability
            WHERE test_center_id = %s
            ORDER BY availability_slot_id, date_of_availability, start_time_slot
        """,(test_center_id,))

        availabilities = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template('view_availabilities.html', availabilities=availabilities)

    except:
        return render_template('view_availabilities.html')





@app.route('/delete_availability', methods=['POST'])
def delete_availability():
    slot_id = request.form.get('slot_id')
    print("**************SLOT ID************")
    print(slot_id)
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        DELETE FROM test_center_availability
        WHERE availability_slot_id = %s
    """, (slot_id,))

    conn.commit()
    cursor.close()
    conn.close()

    flash("Availability slot deleted.", "success")
    return redirect(url_for('view_availabilities'))


@app.route('/centers/contract')
def center_contract():

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        user_id = session.get("user_id")
        cursor.execute("""
                SELECT test_center_id FROM test_center
                WHERE user_id = %s
            """, (user_id,))
        test_center_id = cursor.fetchone()
        test_center_id = test_center_id["test_center_id"]
        print("***********TC ID*************")
        print("HERE: " , test_center_id)

        cursor.execute("""
            SELECT test_center_id, center_contract_status, center_start_date, center_end_date, rate_per_seat FROM test_center_contract WHERE test_center_id = %s;
        """,(test_center_id,))

        contract_details = cursor.fetchall()
                        

        cursor.close()
        conn.close()
        return render_template('center_contract.html', contract_details = contract_details)

    except:
        return render_template('center_contract.html')


@app.route('/my_registrations')
def my_registrations():
    # TODO
    return render_template('my_registrations.html')

@app.route('/sponsors/contract')
def sponsor_contract():

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        user_id = session.get("user_id")
        cursor.execute("""
                SELECT exam_sponsor_id FROM exam_sponsor
                WHERE user_id = %s
            """, (user_id,))
        sponsor_id = cursor.fetchone()
        sponsor_id = sponsor_id["exam_sponsor_id"]
        print("***********ES ID*************")
        print(sponsor_id)

        cursor.execute("""
            SELECT 
                exam_sponsor_id, sponsor_contract_status, sponsor_start_date, sponsor_end_date, seat_commitment, rate_per_tester 
            FROM sponsor_contract 
            WHERE exam_sponsor_id = %s;
        """,(sponsor_id,))

        contract_details = cursor.fetchall()
                        

        cursor.close()
        conn.close()
        return render_template('sponsor_contract.html', contract_details = contract_details)

    except:
        return render_template('sponsor_contract.html')

@app.route('/sponsors/exams')
def view_sponsor_exams():    
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        user_id = session.get("user_id")
        cursor.execute("""
                SELECT exam_sponsor_id FROM exam_sponsor
                WHERE user_id = %s
            """, (user_id,))
        sponsor_id = cursor.fetchone()
        sponsor_id = sponsor_id["exam_sponsor_id"]
        print("***********ES ID*************")
        print(sponsor_id)

        cursor.execute("""
            SELECT e.exam_id, e.exam_name, e.exam_duration, domain, exam_regs.reg_count AS reg_count, exam_schedule.schedule_count AS schedule_count
                FROM exam e
            LEFT JOIN (
                SELECT exam_id, COUNT(*) AS reg_count
                FROM registered_test_takers r
                WHERE exam_sponsor_id = %s
                AND appointment_status = "Scheduled"
                OR appointment_status IS NULL                
                GROUP BY exam_id) exam_regs
                ON e.exam_id = exam_regs.exam_id
                LEFT JOIN (
                    SELECT exam_id, COUNT(*) AS schedule_count
                    FROM scheduled_test_takers s
                    WHERE exam_sponsor_id = %s AND appointment_status = 'Scheduled'
                    GROUP BY exam_id) exam_schedule
                ON e.exam_id = exam_schedule.exam_id
                WHERE exam_sponsor_id = %s
        """,(sponsor_id, sponsor_id, sponsor_id))

        exams = cursor.fetchall()
        print("CURSOR: ", exams)                 
        cursor.close()
        conn.close()
        return render_template('view_sponsor_exams.html', exams = exams)

    except:

        return render_template('view_sponsor_exams.html')


@app.route('/sponsors/add_exam',methods=['GET', 'POST'])
def add_sponsor_exams():    

    if request.method == 'POST':
        exam_name = request.form.get('exam_name')     
        exam_duration = request.form.get('exam_duration')
        domain = request.form.get('domain')  
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)
    

    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        user_id = session.get("user_id")
        cursor.execute("""
                SELECT exam_sponsor_id FROM exam_sponsor
                WHERE user_id = %s
            """, (user_id,))
        sponsor_id = cursor.fetchone()
        sponsor_id = sponsor_id["exam_sponsor_id"]
        print("***********ES ID*************")
        print("HELLO: " , sponsor_id)

         # ---- 1) Check if any exam already exists with this sponsor (best practice) ----
        cursor.execute("""
            SELECT exam_id FROM exam WHERE exam_name = %s AND exam_sponsor_id = %s
        """, (exam_name,sponsor_id,))
        existing = cursor.fetchone()
        print("EXISTING: " ,existing)

        if existing:
            cursor.close()
            conn.close()
            flash("This exam already is registered.", "error")
            return redirect(url_for("add_sponsor_exams"))
      
        # ---- 2) Insert new exam ----
        cursor.execute("""
            INSERT INTO exam(exam_sponsor_id, exam_name, exam_duration, domain )
            VALUES
            (%s, %s, %s, %s)
        """, (sponsor_id, exam_name, exam_duration, domain,))

        conn.commit()
        cursor.close()
        conn.close()
        flash("Exam added successfully! Click \"Add Another Exam\" to add another", "success")
        return render_template('add_sponsor_exams.html')

    except:

        return render_template('add_sponsor_exams.html')


if __name__ == '__main__':
    app.run(debug=True)
