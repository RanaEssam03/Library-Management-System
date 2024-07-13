from services.book_services import app

# This script runs the Flask application for book services.
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
 