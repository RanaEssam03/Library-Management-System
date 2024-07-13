import React from 'react';
import { motion } from 'framer-motion';

const Contact = () => {
  return (
    <section id="contact" className="bg-gray-100 py-20">
      <div className="container mx-auto text-center">
        <motion.h2 
          className="text-4xl font-bold text-gray-800 mb-6"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true }}
        >
          Contact Us
        </motion.h2>
        <motion.p 
          className="text-xl text-gray-600 max-w-3xl mx-auto mb-8"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          viewport={{ once: true }}
        >
          Have any questions or need more information? Feel free to get in touch with us!
        </motion.p>
        <motion.form 
          className="max-w-xl mx-auto bg-white p-8 rounded-lg shadow-lg"
          initial={{ opacity: 0, scale: 0.8 }}
          whileInView={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5, delay: 0.5 }}
          viewport={{ once: true }}
        >
          <div className="mb-6">
            <label className="block text-gray-700 text-lg font-bold mb-2" htmlFor="name">
              Name
            </label>
            <input 
              type="text" 
              id="name" 
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600" 
              placeholder="Enter your name" 
            />
          </div>
          <div className="mb-6">
            <label className="block text-gray-700 text-lg font-bold mb-2" htmlFor="email">
              Email
            </label>
            <input 
              type="email" 
              id="email" 
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600" 
              placeholder="Enter your email" 
            />
          </div>
          <div className="mb-6">
            <label className="block text-gray-700 text-lg font-bold mb-2" htmlFor="message">
              Message
            </label>
            <textarea 
              id="message" 
              rows="4" 
              className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600" 
              placeholder="Enter your message" 
            />
          </div>
          <motion.button 
            type="submit"
            className="bg-blue-600 text-white px-6 py-3 rounded-full text-lg hover:bg-blue-700"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            Send Message
          </motion.button>
        </motion.form>
      </div>
    </section>
  );
};

export default Contact;
