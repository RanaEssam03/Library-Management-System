
from flask import Flask, json, jsonify, request


from controler.book_controller import BookController
from controler.error_handler import InvalidUsage
from repository.book_repositiry import BookRepository





app = Flask(__name__)

bookRepo= BookRepository()
bookController = BookController(bookRepo= bookRepo)
@app.route("/")
def hello_world():
    return "hello_world"


@app.errorhandler(InvalidUsage)
def handle_invalid_usage(error):
    response = jsonify(error.to_dict())
    response.status_code = error.status_code
    return response

@app.route("/get-all-books", methods = ["GET"])
def getAllBooks():
    books = bookController.get_books()
    return jsonify([book.json() for book in books])



@app.route("/get-book/<int:id>",methods = ["GET"])
def getBookById(id):
    try:
        book = bookController.get_book_by_id(id)
        return book.json()
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route("/add-book/", methods = ["POST"])
def addBook():
    data = request.json
    if not data or not all(key in data for key in ("title", "author")):
        return jsonify({"error": "Invalid input"}), 400
    return jsonify({"isbn": bookController.add_book(data)}), 200



@app.route("/delete-book/<int:id>", methods = ["DELETE"])
def deleteBook(id):
    try:
        bookController.delete_book(id)
        return jsonify({"message": "Book deleted successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
@app.route("/borrow-book/<int:id>", methods = ["PUT"])
def borrowBook(id):
    try:
        bookController.borrow_book(id)
        return jsonify({"message": "Book borrowed successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    
@app.route("/return-book/<int:id>", methods = ["PUT"])
def returnBook(id):
    try:
        bookController.returnBook(id)
        return jsonify({"message": "Book returned successfully"})
    except InvalidUsage as e:
        return handle_invalid_usage(e)
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    


if __name__ == "__main__":
    app.run(debug=True)


