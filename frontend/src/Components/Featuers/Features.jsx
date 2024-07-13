import React from 'react';
import { motion } from 'framer-motion';

const features = [
  { title: 'Wide Collection', description: 'Access thousands of books in various genres.', icon: '📚' },
  { title: 'Digital Resources', description: 'E-books, audiobooks, and online databases.', icon: '💻' },
  { title: 'Community Events', description: 'Join book clubs, workshops, and more.', icon: '🎉' },
  { title: 'Quiet Study Areas', description: 'Peaceful spaces for focused reading and studying.', icon: '🤫' },
  { title: 'Children\'s Programs', description: 'Engaging activities and storytimes for kids.', icon: '👶' },
  { title: 'Free Wi-Fi', description: 'Stay connected with our high-speed internet.', icon: '📶' },
];

const Features = () => {
  return (
    <section id="features" className="bg-white py-20">
      <div className="container mx-auto text-center">
        <h2 className="text-4xl font-bold text-gray-800 mb-10">Features</h2>
        <div className="grid md:grid-cols-3 gap-8">
          {features.map((feature, index) => (
            <motion.div 
              key={index}
              className="p-6 bg-gray-100 rounded-lg shadow-lg"
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.2 }}
              viewport={{ once: true }}
            >
              <div className="text-5xl">{feature.icon}</div>
              <h3 className="text-2xl font-bold text-gray-700 mt-4">{feature.title}</h3>
              <p className="text-gray-600 mt-2">{feature.description}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Features;
