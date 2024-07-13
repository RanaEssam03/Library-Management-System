from flask import json, jsonify

from models.book import Book


class DataBaseHandler:
    fileName = "Database.json"

    def load(self):
        try:
            with open(self.fileName, "r") as file:
                file_content = file.read()
                
                self.data =json.loads(file_content)
                # convert the data to a list of book objects
                books = []
                for item in self.data:
                    book = Book(title=item["title"], author=item["author"], isbn=item["isbn"], borrowed= item["borrowed"])
                    books.append(book)
                self.books = books
                return self.books
        
        except FileNotFoundError:
            print(f"File '{self.fileName}' not found.")
            self.books = []
            return self.books
    
        
        
    def save(self, books):
            try:
                with open(self.fileName, "w") as file:
                    books_data = [book.json() for book in books]
                    json.dump(books_data, file, indent=4)
            except Exception as e:
                print(f"Error saving data to file '{self.fileName}': {e}")