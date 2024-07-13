from models.book import Book
from repository.file_manager import DataBaseHandler


class BookRepository:
    
    
    
    def __init__(self):
        self.file_manager  =DataBaseHandler()
        self.books = self.file_manager.load()
        maxID = 0
        # get the max ID or ISN to know the id of any new book will be added in the future
        for book in self.books:
            if book.isbn > maxID:
                maxID = book.isbn
        
        self.cnt = maxID +1
        
        
    
    def add_book(self, book):
        # assign a unique id for the new book
        book.isbn = self.cnt
        self.cnt += 1 
        self.books.append(book)
        self.file_manager.save(books=self.books)
        return book.isbn

    def get_all_books(self):
        return self.books

    def get_book_by_id(self, book_id):
        for book in self.books:
            if book.isbn == book_id:
                return book
        return None

    def update_book(self, book):
        for i in range(len(self.books)):
            if self.books[i].isbn == book.isbn:
                self.books[i] = book
                # write through the data in the file
                self.file_manager.save(books=self.books)
                return True
        
        return False

    def delete_book(self, book_id):
        for i in range(len(self.books)):
            if self.books[i].isbn == book_id:
                del self.books[i]
                # write through the data in the file
                self.file_manager.save(books=self.books)
                return True
        return False
    
    

    