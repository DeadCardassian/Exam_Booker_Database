from flask import Flask, session, render_template, request, redirect, url_for, jsonify, flash
from datetime import datetime, date
from functools import wraps
from flask import make_response
import mysql.connector
import bcrypt
import csv



app = Flask(__name__)

app.secret_key = "my_se_key"  # allow flash

def nocache(view):
    @wraps(view)
    def no_cache(*args, **kwargs):
        response = make_response(view(*args, **kwargs))
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"
        return response
    return no_cache

#----------------- DB CONNECTION
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",        
        password="",         
        database="exam_booker"    
    )

#----------------- PUBLIC PAGES
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

#----------------- ALL USERS: Log in, Log out, Create User, Personal Information
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
        # cursor.close()
        # conn.close()

        # ---- 2) user not found ----
        if not user:
            flash("User not found.", "error")
            return render_template('login.html')

        # ---- 3) user_type mismatch ----
        if user['user_type'] != user_type:
            flash("User type does not match this account.", "error")
            return render_template('login.html')

        # ---- 4) check password ----
        user_id = user["user_id"]
        print("************ USER ID *********** ")
        print(user_id)
        stored_hash = user['user_password_h'].encode('utf-8')
  
        if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
            session["user_id"] = user_id
            session["user_type"] = user_type
            # flash("Login successful!", "success")
            if user_type == "TT":
                cursor.execute("""
                SELECT test_taker_id
                FROM test_taker
                WHERE user_id = %s
                """, (user_id,))

                test_taker_id = cursor.fetchone()
                cursor.close()
                conn.close()
                
                if test_taker_id:
                    return redirect(url_for("my_registrations"))
                else: 
                    return redirect(url_for("personal_information", user_id=session.get("user_id"), user_type=session.get("user_type")))
                
            elif user_type == "TC":
                cursor.execute("""
                SELECT test_center_id
                FROM test_center
                WHERE user_id = %s
                """, (user_id,))

                test_center_id = cursor.fetchone()
                cursor.close()
                conn.close()

                if test_center_id: 
                    return redirect(url_for("view_availabilities"))
                else:
                    return redirect(url_for("personal_information", user_id=session.get("user_id"), user_type=session.get("user_type")))
            else: # if ES type
                cursor.execute("""
                SELECT exam_sponsor_id
                FROM exam_sponsor
                WHERE user_id = %s
                """, (user_id,))

                exam_sponsor_id = cursor.fetchone()
                cursor.close()
                conn.close()

                if exam_sponsor_id:
                    return redirect(url_for("view_sponsor_exams", user_id=user_id))
                else:
                    return redirect(url_for("personal_information", user_id=session.get("user_id"), user_type=session.get("user_type")))

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

@app.route('/create_user', methods=['GET', 'POST'])
def create_user():
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
            return render_template('create_user.html')

        # ---- 2) bcrypt hash ----
        hashed_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
        hashed_pw = hashed_pw.decode('utf-8')

        # ---- 3) Insert new user ----
        cursor.execute("""
            INSERT INTO user (user_email, user_password_h, user_type)
            VALUES (%s, %s, %s)
        """, (email, hashed_pw, user_type))

        user_id = cursor.lastrowid
        session["user_id"] = user_id
        session["user_type"] = user_type
        conn.commit()
        cursor.close()
        conn.close()

        if user_type == "TT":
            return redirect(url_for("personal_information", user_id=session.get("user_id"), user_type=session.get("user_type")))
        elif user_type == "TC":
            return redirect(url_for("personal_information", user_id=user_id, user_type=session.get("user_type")))
        else: #if user is ES
            return redirect(url_for("personal_information", user_id=user_id, user_type=session.get("user_type")))

    return render_template('create_user.html')

@app.route('/personal_information', methods=['GET', 'POST'])
def personal_information():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    user_id = session.get("user_id")
    user_type = session.get("user_type")

    if request.method == 'POST':
        if user_type == "TT":
            first_name = request.form.get('first_name')     
            last_name = request.form.get('last_name')
            phone_number = request.form.get('phone_number') 
            street = request.form.get('street')     
            city = request.form.get('city')
            state_address = request.form.get('state_address')     
            country = request.form.get('country')
            zip_code = request.form.get('zip_code') 

            cursor.execute("""
                SELECT test_taker_id FROM test_taker WHERE user_id = %s
            """, (user_id,))
            existing = cursor.fetchone()

            if existing:
                cursor.close()
                conn.close()
                flash("Personal information already completed", "error")
                return render_template('my_registrations.html')
            print("user_id from session:", user_id)

            cursor.execute("SELECT * FROM user WHERE user_id = %s", (user_id,))
            user_exists = cursor.fetchone()
            print("user exists:", user_exists)

            cursor.execute("""
                INSERT INTO test_taker (first_name, last_name, phone_number, street, city, state_address, country, zip_code, user_id)
                VALUES (%s, %s, %s, %s, %s, %s,%s, %s, %s)
            """, (first_name, last_name, phone_number, street, city, state_address, country, zip_code,user_id, ))

            conn.commit()
            cursor.close()
            conn.close()

            return redirect(url_for("my_registrations", user_id=user_id))
        
        if user_type == "TC":
            test_center_name = request.form.get('test_center_name')     
            test_center_street = request.form.get('test_center_street')     
            test_center_city = request.form.get('test_center_city')
            test_center_state = request.form.get('test_center_state')     
            test_center_country = request.form.get('test_center_country')
            test_center_zip_code = request.form.get('test_center_zip_code') 

            cursor.execute("""
                SELECT test_center_id FROM test_center WHERE user_id = %s
            """, (user_id,))
            existing = cursor.fetchone()

            if existing:
                cursor.close()
                conn.close()
                flash("Test center details already saved", "error")
                return render_template('view_availabilities.html')
            
          
            cursor.execute("""
                INSERT INTO test_center (test_center_name, test_center_street, test_center_city, test_center_state, test_center_country, test_center_zip_code, user_id)
                VALUES (%s, %s, %s, %s, %s, %s,%s)
            """, (test_center_name, test_center_street, test_center_city, test_center_state, test_center_country, test_center_zip_code, user_id,))

            conn.commit()
            cursor.close()
            conn.close()

            return redirect(url_for("view_availabilities", user_id=user_id))
        if user_type == "ES":
            sponsor_name = request.form.get('sponsor_name') 

            cursor.execute("""
                SELECT exam_sponsor_id FROM exam_sponsor WHERE user_id = %s
            """, (user_id,))
            existing = cursor.fetchone()

            if existing:
                cursor.close()
                conn.close()
                flash("Exam Sponsor details already saved", "error")
                return render_template('sponsor_contract.html')
            
          
            cursor.execute("""
                INSERT INTO exam_sponsor (sponsor_name, user_id)
                VALUES (%s, %s)
            """, (sponsor_name, user_id,))

            conn.commit()
            cursor.close()
            conn.close()

            return redirect(url_for("view_sponsor_exams", user_id=user_id))

    return render_template('personal_information.html', user_id=user_id, user_type=user_type)

#----------------- TEST TAKER: My Registrations, My Appointments, New Exam Reg, Schedule Exam, Cancel Exam, Reschedule Exam
@app.route('/my_registrations')
@nocache
def my_registrations():
    if "user_id" not in session:
        return redirect(url_for("login"))
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    user_id = session.get("user_id")
    try:
        cursor.execute("""
            SELECT test_taker_id FROM test_taker WHERE user_id = %s
        """, (user_id,))

        test_taker_id = cursor.fetchone()
        test_taker_id = test_taker_id["test_taker_id"]
        print("******** TT ID *******")
        print(test_taker_id)
        cursor.execute("""
        SELECT sponsor_name, exam_sponsor_id, exam_name, appointment_status, exam_registration_id
        FROM (
            SELECT 
                s.sponsor_name,
                r.exam_sponsor_id,
                r.exam_name,
                r.appointment_status,
                r.exam_registration_id,
                ROW_NUMBER() OVER (
                    PARTITION BY r.exam_registration_id 
                    ORDER BY CASE WHEN r.appointment_id IS NULL THEN 0 ELSE 1 END,
                    r.appointment_id DESC 
                ) AS rn
            FROM registered_test_takers r
            INNER JOIN exam_sponsor s
                ON s.exam_sponsor_id = r.exam_sponsor_id
            WHERE r.test_taker_id = %s
        ) AS ranked
        WHERE rn = 1
        ORDER BY sponsor_name, exam_name;
        """, (test_taker_id, ))

        # cursor.execute("""
        #     SELECT s.sponsor_name, r.exam_sponsor_id, r.exam_name, r.appointment_status, r.exam_registration_id FROM registered_test_takers r
        #     INNER JOIN exam_sponsor s
        #     ON s.exam_sponsor_id = r.exam_sponsor_id                       
        #     WHERE test_taker_id = %s
        #     ORDER BY s.sponsor_name, r.exam_name
        # """, (test_taker_id, ))

        registrations = cursor.fetchall()
        cursor.close()
        conn.close()

        return render_template("my_registrations.html", registrations=registrations)
    except:     
        return render_template("my_registrations.html")    


@app.route('/my_appointments')
def my_appointments():
    if "user_id" not in session:
        return redirect(url_for("login"))
    
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    user_id = session.get("user_id")
    try:
        cursor.execute("""
            SELECT test_taker_id FROM test_taker WHERE user_id = %s
        """, (user_id,))

        test_taker_id = cursor.fetchone()
        test_taker_id = test_taker_id["test_taker_id"]
        print("******** TT ID *******")
        print(test_taker_id)

        cursor.execute("""
        WITH ranked AS (
            SELECT
                s.sponsor_name,e.exam_name,a.exam_registration_id,a.exam_duration,a.appointment_status,
                a.accomodations,a.date_of_availability,a.start_time_slot,a.test_center_name,
                a.test_center_street,a.test_center_city,a.test_center_state,a.test_center_country,
                a.test_center_zip_code,
                ROW_NUMBER() OVER (
                    PARTITION BY a.exam_registration_id
                    ORDER BY CASE WHEN a.appointment_id IS NULL THEN 0 ELSE 1 END,
                    a.appointment_id DESC
                ) AS row_num
            FROM scheduled_test_takers a
            LEFT JOIN exam_sponsor s
                ON a.exam_sponsor_id = s.exam_sponsor_id
            LEFT JOIN exam e
                ON a.exam_id = e.exam_id
            WHERE a.test_taker_id = %s
        )
        SELECT *
        FROM ranked
        WHERE row_num = 1
        ORDER BY sponsor_name, exam_name;
        """, (test_taker_id, ))


        appointments = cursor.fetchall()
        cursor.close()
        conn.close()

        return render_template("my_appointments.html", appointments=appointments)
    except:     
        return render_template("my_appointments.html")   

@app.route('/schedule_exam', methods=['POST', 'GET'])
def schedule_exam():
    exam_registration_id = request.form.get("exam_registration_id")
    selection = request.form.get('selection')

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT test_center_city
        FROM (
            SELECT DISTINCT test_center_city FROM test_centers_with_availability 
            UNION ALL 
            SELECT DISTINCT test_center_country FROM test_centers_with_availability
        ) AS combined 
        ORDER BY test_center_city
    """)
    cities = cursor.fetchall()

    user_id = session.get("user_id")
    cursor.execute("""
        SELECT test_taker_id FROM test_taker WHERE user_id = %s
    """, (user_id,))
    test_taker_id = cursor.fetchone()
    cursor.fetchall()
    test_taker_id = test_taker_id["test_taker_id"]

    cursor.execute("""
        SELECT r.exam_registration_id, s.sponsor_name, r.exam_name
        FROM registered_test_takers r
        LEFT JOIN exam_sponsor s
        ON r.exam_sponsor_id = s.exam_sponsor_id
        WHERE r.exam_registration_id = %s
    """, (exam_registration_id, ))

    registration = cursor.fetchone()
    cursor.fetchall()

    sponsor_name = registration["sponsor_name"]
    exam_name = registration["exam_name"]

    cursor.execute("""
    SELECT *
    FROM test_centers_with_availability tca_view
    WHERE tca_view.slot_duration > (
        SELECT exam_duration
        FROM (
            SELECT
                reg_view.exam_duration,
                ROW_NUMBER() OVER (
                    PARTITION BY reg_view.exam_registration_id
                    ORDER BY CASE WHEN reg_view.appointment_id IS NULL THEN 0 ELSE 1 END,
                    reg_view.appointment_id DESC
                ) AS rn
            FROM registered_test_takers reg_view
            WHERE reg_view.test_taker_id = %s
            AND reg_view.exam_registration_id = %s
        ) AS ranked
        WHERE rn = 1
    )
    AND (tca_view.seat_capacity - tca_view.scheduled_count) > 0
    ORDER BY test_center_name ASC, date_of_availability ASC, start_time_slot ASC
""", (test_taker_id, exam_registration_id,))

    availabilities = cursor.fetchall()

    cursor.close()
    conn.close()

    return render_template("schedule_exam.html", selection=selection,cities=cities, sponsor_name=sponsor_name,exam_name=exam_name,availabilities=availabilities,test_taker_id=test_taker_id,exam_registration_id=exam_registration_id)

@app.route('/schedule_exam/search', methods=['POST', 'GET'])
def city_search():
    selection = request.form.get('selection')
    sponsor_name = request.form.get("sponsor_name")
    exam_name = request.form.get("exam_name")
    exam_registration_id = request.form.get("exam_registration_id")
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT test_taker_id FROM test_taker WHERE user_id = %s
    """, (user_id,))

    test_taker_id = cursor.fetchone()
    cursor.fetchall()
    test_taker_id = test_taker_id["test_taker_id"]

    cursor.execute("""
        SELECT test_center_city
        FROM (
            SELECT DISTINCT test_center_city FROM test_centers_with_availability 
            UNION ALL 
            SELECT DISTINCT test_center_country FROM test_centers_with_availability
        ) AS combined 
        ORDER BY test_center_city
    """)

    cities = cursor.fetchall()
    cursor.close()
    conn.close()

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT *
        FROM test_centers_with_availability tca_view
        WHERE tca_view.slot_duration > (
            SELECT exam_duration
            FROM (
                SELECT
                    reg_view.exam_duration,
                    ROW_NUMBER() OVER (
                        PARTITION BY reg_view.exam_registration_id
                        ORDER BY CASE WHEN reg_view.appointment_id IS NULL THEN 0 ELSE 1 END,
                    reg_view.appointment_id DESC
                    ) AS rn
                FROM registered_test_takers reg_view
                WHERE reg_view.test_taker_id = %s
                AND reg_view.exam_registration_id = %s
            ) AS ranked
            WHERE rn = 1
        )
        AND (tca_view.seat_capacity - tca_view.scheduled_count) > 0
        AND tca_view.test_center_city = %s
        OR tca_view.test_center_state = %s
        OR tca_view.test_center_country = %s
        OR tca_view.test_center_zip_code = %s
        ORDER BY test_center_name ASC, date_of_availability ASC, start_time_slot ASC;
    """, (test_taker_id, exam_registration_id, selection, selection, selection, selection ))
    
    availabilities = cursor.fetchall()


    return render_template("schedule_exam.html", selection=selection, sponsor_name=sponsor_name, exam_name = exam_name, cities=cities, availabilities= availabilities, test_taker_id = test_taker_id, exam_registration_id = exam_registration_id)

@app.route('/book_appointment', methods=['POST', 'GET'])
def book_appointment():
    availability_slot_id = request.form.get("availability_slot_id")
    exam_registration_id = request.form.get("exam_registration_id")
    print("******** EXAM REG ID *******")
    print(exam_registration_id)
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT test_taker_id FROM test_taker WHERE user_id = %s
    """, (user_id,))

    test_taker_id = cursor.fetchone()
    test_taker_id = test_taker_id["test_taker_id"]

    cursor.execute("""
        SELECT appointment_status
        FROM (
            SELECT 
                r.appointment_status,
                ROW_NUMBER() OVER (
                    PARTITION BY r.exam_registration_id
                    ORDER BY CASE WHEN r.appointment_id IS NULL THEN 0 ELSE 1 END,
                    r.appointment_id DESC
                ) AS rn
            FROM registered_test_takers r
            WHERE r.exam_registration_id = %s
        ) AS ranked
        WHERE rn = 1;
    """, (exam_registration_id,))

    appointment_status = cursor.fetchone()
    appointment_status = appointment_status["appointment_status"] if appointment_status else None

    if appointment_status == "Scheduled":
        cursor.execute("""
            UPDATE appointment
            SET appointment_status = 'Cancelled'
            WHERE exam_registration_id = %s;
        """, (exam_registration_id, ))


    cursor.execute("""
        INSERT INTO appointment (exam_registration_id,
        appointment_status, availability_slot_id)
        VALUES
        (%s, 'Scheduled', %s);
    """, (exam_registration_id,availability_slot_id, ))

    conn.commit()
    cursor.close()
    conn.close()

    return redirect(url_for('my_appointments'))


@app.route('/cancel_appointment', methods=['POST', 'GET'])
def cancel_appointment():
    availability_slot_id = request.form.get("availability_slot_id")
    exam_registration_id = request.form.get("exam_registration_id")
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT test_taker_id FROM test_taker WHERE user_id = %s
    """, (user_id,))

    test_taker_id = cursor.fetchone()
    test_taker_id = test_taker_id["test_taker_id"]

    cursor.execute("""
        UPDATE appointment
        SET appointment_status = 'Cancelled'
        WHERE exam_registration_id = %s;
    """, (exam_registration_id, ))

    conn.commit()
    cursor.close()
    conn.close()

    return redirect(url_for('my_appointments'))

@app.route('/new_exam_registration', methods=['GET', 'POST'])
def new_exam_registration():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT DISTINCT sponsor_name, exam_sponsor_id FROM sponsor_exam_details ORDER BY sponsor_name;")
    sponsors = cursor.fetchall()

    sponsor_selection = None
    exam_selection = None
    exams = []
    cost = 0

    if request.method == 'POST':
        sponsor_selection = request.form.get('sponsor_name')
        exam_selection = request.form.get('exam_name')

        cursor.execute("""
            SELECT exam_name FROM sponsor_exam_details 
            WHERE sponsor_name = %s
            ORDER BY exam_name
        """, (sponsor_selection,))
        exams = cursor.fetchall()
        
        if exam_selection:
            cursor.execute("""
            SELECT exam_id FROM sponsor_exam_details
            WHERE exam_name = %s
            AND sponsor_name = %s
        """, (exam_selection, sponsor_selection, ))
            
            exam_id = cursor.fetchone()
            exam_id = exam_id["exam_id"]

            cursor.execute("""
            SELECT cost FROM exam
            WHERE exam_id = %s
            """, (exam_id,))

            cost = cursor.fetchone()
            cost = cost["cost"]

    cursor.close()
    conn.close()

    return render_template(
        "new_exam_registration.html",
        sponsors=sponsors,
        exams=exams,
        sponsor_name=sponsor_selection,
        exam_name=exam_selection,
        cost=cost

    )

@app.route('/create_registration', methods=['POST', 'GET'])
def create_registration():
    exam_name = request.form.get("exam_name")
    sponsor_name = request.form.get("sponsor_name")
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("""
        SELECT test_taker_id FROM test_taker WHERE user_id = %s
    """, (user_id,))

    test_taker_id = cursor.fetchone()
    test_taker_id = test_taker_id["test_taker_id"]

    cursor.execute("""
        SELECT exam_id FROM sponsor_exam_details
        WHERE exam_name = %s
        AND sponsor_name = %s
    """, (exam_name, sponsor_name, ))

    exam_id = cursor.fetchone()
    exam_id = exam_id["exam_id"]

    cursor.execute("""
    SELECT cost FROM exam
    WHERE exam_id = %s
    """, (exam_id,))

    cost = cursor.fetchone()
    cost = cost["cost"]

    cursor.execute("""
    SELECT invoice_number FROM exam_registration
    ORDER BY exam_registration_id DESC
    LIMIT 1
    """)

    latest_invoice = cursor.fetchone()
    latest_invoice = latest_invoice["invoice_number"]
    
    latest_invoice = latest_invoice.split("-")[1]
    try:
        latest_invoice = int(latest_invoice)
    except ValueError:
        print("error converting invoice number to int")

    invoice_number = latest_invoice + 1
    invoice_number = f"INV-{invoice_number:0{6}d}"
    print("********* invoice_number ***********")
    print(invoice_number)

    cursor.execute("""
        INSERT INTO exam_registration(exam_id, test_taker_id, invoice_number,
        registration_date)
        VALUES (%s,%s,%s,CURDATE());
    """, (exam_id, test_taker_id, invoice_number))

    conn.commit()
    cursor.close()
    conn.close()

    return redirect(url_for('my_registrations'))

#----------------- TEST CENTER: View Availability, Delete Availability, Upload Availability, View Contract
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


            # ---- 1) Check that exam sponsor has a contract ----
            cursor.execute("""
                SELECT test_center_contract_id FROM test_center_contract
                WHERE test_center_id = %s
            """, (test_center_id,))
            test_center_contract_id = cursor.fetchone()

            if test_center_contract_id:
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
            else: 
                flash("Adding Availability Disabled. Please contact an Exam Booker Administrator to set up a contract first.", "error")
                return render_template('upload_availabilities.html')  
                          
            cursor.close()
            conn.close()

            flash(f"Uploaded {count} availability slots.", "success")

        except Exception as e:
            flash(f"Upload failed: {e}", "error")

        return redirect(url_for('upload_availabilities'))

    return render_template('upload_availabilities.html')


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

#----------------- EXAM SPONSOR: View Exams, Add Exam, View Contract
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
            SELECT e.exam_id, e.exam_name, e.exam_duration, domain, cost, exam_regs.reg_count AS reg_count, exam_schedule.schedule_count AS schedule_count
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
        cost = request.form.get('cost')  
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

         # ---- 1) Check that exam sponsor has a contract ----
        cursor.execute("""
            SELECT sponsor_contract_id FROM sponsor_contract
            WHERE exam_sponsor_id = %s
        """, (sponsor_id,))
        sponsor_contract_id = cursor.fetchone()

        if sponsor_contract_id:
            # ---- 2) Check if any exam already exists with this sponsor ----
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
        
            # ---- 3) Insert new exam ----
            cursor.execute("""
                INSERT INTO exam(exam_sponsor_id, exam_name, exam_duration, domain, cost )
                VALUES
                (%s, %s, %s, %s, %s)
            """, (sponsor_id, exam_name, exam_duration, domain, cost))

            conn.commit()
            cursor.close()
            conn.close()
            flash("Exam added successfully!", "success")
            return render_template('add_sponsor_exams.html')
        else:
            flash("Adding Exams Disabled. Please contact an Exam Booker Administrator to set up a contract first.", "error")
            return render_template('add_sponsor_exams.html')
        
    except:
        return render_template('add_sponsor_exams.html')

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
    

#----------------- OTHER

@app.template_filter("friendly_date")
def friendly_date(value):
    return value.strftime("%B %d, %Y")

@app.template_filter("friendly_time")
def friendly_time(value):
    total_seconds = value.total_seconds()
    hours = int(total_seconds // 3600)
    minutes = int((total_seconds % 3600) // 60)

    return datetime.strptime(f"{hours:02d}:{minutes:02d}", "%H:%M").strftime("%I:%M %p").lstrip("0")


if __name__ == '__main__':
    app.run(debug=True)
