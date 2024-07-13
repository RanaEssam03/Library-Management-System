import React from 'react';
import { motion } from 'framer-motion';
import './Hero.css';
const Hero = () => {
  return (
    <section className="bg-gray-100 py-20 flex items-center  justify-center relative h-[95vh] overflow-hidden">
  
      <div className="container mx-auto   hero flex flex-col items-center relative z-10">
        <motion.h1 
          className="text-5xl font-bold text-gray-800 mb-4"
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1 }}
        >
          Welcome to Our Library
        </motion.h1>
        <motion.h2 
          className="text-3xl text-gray-700 mb-6"
          initial={{ opacity: 0, y: -50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.3 }}
        >
          Your Gateway to Knowledge and Imagination
        </motion.h2>
        <motion.p 
          className="text-xl text-gray-600 mb-8"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 0.6 }}
        >
          Discover a world of knowledge and imagination with our extensive collection of books, digital resources, and community events.
        </motion.p>
        <div className="flex space-x-4">
          <motion.a 
            href="#"
            className="bg-blue-600 text-white px-6 py-3 rounded-full text-lg hover:bg-blue-700"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, delay: 0.9 }}
          >
            Get Started
          </motion.a>
          <motion.a 
            href="#about"
            className="bg-white text-blue-600 px-6 py-3 rounded-full text-lg border border-blue-600 hover:bg-gray-200"
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 1, delay: 1.1 }}
          >
            Learn More
          </motion.a>
        </div>
        <div>
        <motion.div 
          className="absolute left-0 right-0 flex justify-center mb-4"
          initial={{ opacity: 0, y: 50 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1, delay: 1.3 }}
        >
          <svg className="w-6 h-6 text-gray-800 animate-bounce" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M19 9l-7 7-7-7"></path>
          </svg>
        </motion.div>
        </div>
      </div>

    </section>
  );
};

export default Hero;
