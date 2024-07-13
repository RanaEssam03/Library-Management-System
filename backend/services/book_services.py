from flask import Flask, json, jsonify, request
from flask_cors import CORS

# Importing necessary controllers and error handling
from controller.book_controller import BookController
from controller.error_handler import InvalidUsage
from repository.book_repositiry import BookRepository

# Initializing repository and controller instances
bookRepo = BookRepository()
bookController = BookController(bookRepo=bookRepo)

# Initializing Flask application
app = Flask(__name__)
CORS(app)

# Route for the root endpoint
@app.route("/")
def hello_world():
    return "hello_world"

# Error handler for InvalidUsage exceptions
@app.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict()) 
    response.status_code = error.status_code
    return response

# Route to get all books
@app.route("/get-all-books", methods=["GET"])
def getAllBooks():
    books = bookController.get_books()
    return jsonify([book.json() for book in books])

# Route to get a specific book by ID
@app.route("/get-book/<int:id>", methods=["GET"])
def getBookById(id):
    try:
        book = bookController.get_book_by_id(id)
        return book.json()
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route to add a new book
@app.route("/add-book", methods=["POST"])
def addBook():
    data = request.json
    if not data or not all(key in data for key in ("title", "author")):
        return jsonify({"error": "Invalid input"}), 400
    return jsonify({"isbn": bookController.add_book(data)}), 200

# Route to delete a book by ID
@app.route("/delete-book/<int:id>", methods=["DELETE"])
def deleteBook(id):
    try:
        bookController.delete_book(id)
        return jsonify({"message": "Book deleted successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route to borrow a book by ID
@app.route("/borrow-book/<int:id>", methods=["PUT"])
def borrowBook(id):
    try:
        bookController.borrow_book(id)
        return jsonify({"message": "Book borrowed successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Route to return a borrowed book by ID
@app.route("/return-book/<int:id>", methods=["PUT"])
def returnBook(id):
    try:
        bookController.returnBook(id)
        return jsonify({"message": "Book returned successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
