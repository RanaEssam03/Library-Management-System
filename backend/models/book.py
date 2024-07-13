class Book:
    def __init__(self, title, author, isbn, borrowed = False):
        self.isbn = isbn
        self.title = title
        self.author = author
        self.borrowed = borrowed
        
    def json(self):
        return {
            "title": self.title,
            "author": self.author,
            "isbn": self.isbn,
            "borrowed": self.borrowed
        }

    def __str__(self):
        return f"{self.title} by {self.author}"