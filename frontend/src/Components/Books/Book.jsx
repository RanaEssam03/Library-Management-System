import React, { useState } from 'react';
import axios from 'axios';
import { useQuery, useMutation, useQueryClient, QueryClient, QueryClientProvider } from 'react-query';
import { motion, AnimatePresence } from 'framer-motion';
import { ToastContainer, toast } from 'react-toastify';
import Modal from 'react-modal';
import 'react-toastify/dist/ReactToastify.css';

// Create a client
const queryClient = new QueryClient();

const fetchBooks = async () => {
    const res = await axios.get('http://flask-app-service.default.svc.cluster.local:81/get-all-books');
    return res.data;
};

const deleteBook = async (id) => {
    await axios.delete(`http://flask-app-service.default.svc.cluster.local:81/delete-book/${id}`);
};

const borrowBook = async (id) => {
    await axios.put(`http://flask-app-service.default.svc.cluster.local:81/borrow-book/${id}`);
};

const addBook = async (newBook) => {
    await axios.post('http://flask-app-service.default.svc.cluster.local:81/add-book', newBook);
};

const BookCard = ({ book, onDelete, onBorrow }) => {
    return (
        <motion.div 
            className="w-64 h-56 bg-white shadow-lg rounded-lg relative overflow-hidden ring-2 ring-blue-600 m-4"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -50 }}
            transition={{ duration: 0.5 }}
        >
            <div className="px-6 py-4">
                <h2 className="text-xl font-bold text-blue-600">{book.title}</h2>
                <p className="text-gray-700 mt-2">Author: {book.author}</p>
                <p className="text-gray-700 mt-2">ISBN: {book.isbn}</p>
                <p className={`text-gray-700 mt-2 ${book.borrowed ? 'text-red-500' : 'text-green-500'}`}>
                    {book.borrowed ? 'Borrowed' : 'Available'}
                </p>
            </div>
            <div className="absolute bottom-1 right-1 flex gap-3">
                <p 
                    className="del p-1 px-3 rounded-lg border border-blue-500 text-blue-600 hover:bg-blue-600 hover:text-white transition-all ease-out cursor-pointer"
                    onClick={() => onBorrow(book.isbn)}
                >
                    B
                </p>
                <p 
                    className="del p-1 px-3 rounded-lg border border-red-500 text-red-600 hover:bg-red-600 hover:text-white transition-all ease-out cursor-pointer"
                    onClick={() => onDelete(book.isbn)}
                >
                    -
                </p>
            </div>
        </motion.div>
    );
};

const Book = () => {
    const [newBook, setNewBook] = useState({ title: '', author: '' });
    const [modalIsOpen, setModalIsOpen] = useState(false);
    const queryClient = useQueryClient();
    
    const { data: books, error, isLoading } = useQuery('books', fetchBooks);

    const deleteMutation = useMutation(deleteBook, {
        onSuccess: () => {
            toast.success('Book deleted successfully!', {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
            queryClient.invalidateQueries('books');
        },
        onError: (err) => {
            toast.error(`Error: ${err.message}`, {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
        }
    });

    const borrowMutation = useMutation(borrowBook, {
        onSuccess: () => {
            toast.success('Book borrowed successfully!', {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
            queryClient.invalidateQueries('books');
        },
        onError: (err) => {
            toast.error(`Error: ${err.message}`, {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
        }
    });

    const addMutation = useMutation(addBook, {
        onSuccess: () => {
            toast.success('Book added successfully!', {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
            queryClient.invalidateQueries('books');
            setNewBook({ title: '', author: '' });
            setModalIsOpen(false);
        },
        onError: (err) => {
            toast.error(`Error: ${err.message}`, {
                position: "top-right",
                autoClose: 5000,
                hideProgressBar: false,
                closeOnClick: true,
                pauseOnHover: true,
                draggable: true,
                progress: undefined,
                theme: "light",
            });
        }
    });

    const handleAddBook = (e) => {
        e.preventDefault();
        addMutation.mutate(newBook);
    };

    if (isLoading) return <p>Loading...</p>;
    if (error) return <p>Error: {error.message}</p>;

    return (
        <div className="min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4">
            <ToastContainer />
            <motion.h2 
                className="text-5xl font-bold text-gray-800 mb-12"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.5 }}
            >
                Our Books
            </motion.h2>
            <button 
                onClick={() => setModalIsOpen(true)} 
                className="mb-8 p-2 bg-blue-600 text-white rounded"
            >
                Add Book
            </button>
            <AnimatePresence>
                {modalIsOpen && (
                    <motion.div
                        initial={{ opacity: 0, y: -50 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: 50 }}
                        transition={{ duration: 0.5 }}
                    >
                        <Modal
                            isOpen={modalIsOpen}
                            onRequestClose={() => setModalIsOpen(false)}
                            contentLabel="Add Book"
                            className="bg-white p-6 rounded shadow-lg max-w-md mx-auto mt-10"
                            overlayClassName="fixed inset-0 bg-gray-500 bg-opacity-75 flex justify-center items-center"
                        >
                            <h2 className="text-2xl mb-4">Add a New Book</h2>
                            <form onSubmit={handleAddBook} className="flex flex-col">
                                <input 
                                    type="text" 
                                    placeholder="Title" 
                                    value={newBook.title} 
                                    onChange={(e) => setNewBook({ ...newBook, title: e.target.value })} 
                                    className="p-2 mb-2 border border-gray-300 rounded"
                                />
                                <input 
                                    type="text" 
                                    placeholder="Author" 
                                    value={newBook.author} 
                                    onChange={(e) => setNewBook({ ...newBook, author: e.target.value })} 
                                    className="p-2 mb-2 border border-gray-300 rounded"
                                />
                                <button type="submit" className="p-2 bg-blue-600 text-white rounded">Add Book</button>
                            </form>
                            <button 
                                onClick={() => setModalIsOpen(false)} 
                                className="mt-4 p-2 bg-red-600 text-white rounded"
                            >
                                Close
                            </button>
                        </Modal>
                    </motion.div>
                )}
            </AnimatePresence>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {books.map((book, index) => (
                    <BookCard 
                        key={index} 
                        book={book} 
                        onDelete={deleteMutation.mutate} 
                        onBorrow={borrowMutation.mutate} 
                    />
                ))}
            </div>
        </div>
    );
};

const App = () => (
    <QueryClientProvider client={queryClient}>
        <Book />
    </QueryClientProvider>
);

export default App;
