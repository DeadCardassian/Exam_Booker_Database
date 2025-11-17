from flask import Flask, render_template, request, redirect, url_for, jsonify
import mysql.connector

app = Flask(__name__)

# connect db
def get_connection():
    return mysql.connector.connect(
        host="localhost",
        user="root",         # XAMPP
        password="",         # XAMPP
        database="exam_booker"    # your db name
    )

@app.route("/")
def home():

    return render_template("home.html")

@app.route("/about")
def about():
    return render_template("about_us.html")

@app.route("/test_taker_login", methods=["GET", "POST"])
def test_taker_login():
    if request.method == "POST":

        pass
    return render_template("test_taker_login.html")


@app.route("/register")
def register():
    return render_template("registration_page.html")

@app.route("/user")
def users():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM user")   # 换成你的表名
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(rows)     # 返回 JSON 给前端

if __name__ == "__main__":
    app.run(debug=True)
