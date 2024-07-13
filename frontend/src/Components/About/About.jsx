import React from 'react';
import { motion } from 'framer-motion';

const About = () => {
  return (
    <section id="about" className="bg-gray-100 py-24">
      <div className="container mx-auto text-center">
        <motion.h2 
          className="text-5xl font-bold text-gray-800 mb-12"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true }}
        >
          About Us
        </motion.h2>
        <div className="grid md:grid-cols-2 gap-8 items-center">
          <motion.div 
            className="text-left p-8"
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            viewport={{ once: true }}
          >
            <p className="text-xl text-gray-600 mb-4">
              Our library has been serving the community for over 50 years, providing a vast collection of books, digital resources, and community events. Our mission is to foster a love of reading and lifelong learning for all ages.
            </p>
            <p className="text-xl text-gray-600">
              We offer a wide range of services including book lending, digital resources like e-books and audiobooks, and a variety of community programs such as book clubs, workshops, and educational events.
            </p>
          </motion.div>
          <motion.div 
            className="p-8"
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.5 }}
            viewport={{ once: true }}
          >
            <img 
              src="https://st2.depositphotos.com/1017986/9807/i/950/depositphotos_98075974-stock-photo-happy-student-girl-or-woman.jpg" 
              alt="Library" 
              className="w-full h-full object-cover rounded-lg shadow-lg"
            />
          </motion.div>
        </div>

      </div>
    </section>
  );
};

export default About;
