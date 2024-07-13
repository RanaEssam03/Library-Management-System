from flask import jsonify

from controller.error_handler import InvalidUsage
from models.book import Book


class BookController:
    
    def __init__(self, bookRepo):
        self.bookRepo = bookRepo
    

    def add_book(self, data):
       book = Book(author= data["author"], title= data["title"], isbn=0, borrowed=0)
       return self.bookRepo.add_book(book)
        

    def get_books(self):
        return self.bookRepo.get_all_books()

    def get_book_by_id(self, bookId):
        book = self.bookRepo.get_book_by_id(bookId)
        if(not book):
            raise InvalidUsage(message="Book Not Found", status_code= 404)
        return book

    def update_book(self, book):
        self.bookRepo.update_book(book)

    def delete_book(self, book_id):
        if(not self.bookRepo.get_book_by_id(book_id)):
            raise InvalidUsage(message="Book Not Found", status_code= 404)
        self.bookRepo.delete_book(book_id)
        
    def borrow_book(self, book_id):
        book = self.bookRepo.get_book_by_id(book_id)
        if(not book):
            raise InvalidUsage(message="Book Not Found", status_code= 404)
        if(book.borrowed):
            raise InvalidUsage(message="Book Already Borrowed", status_code= 400)
        book.borrowed = True
        self.bookRepo.update_book(book)
        
    def returnBook(self, book_id):
        book = self.bookRepo.get_book_by_id(book_id)
        if(not book):
            raise InvalidUsage(message="Book Not Found", status_code= 404)
        if(not book.borrowed):
            raise InvalidUsage(message="Book Already Returned", status_code= 400)
        book.borrowed = False
        self.bookRepo.update_book(book)