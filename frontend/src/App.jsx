import React from 'react';
import Hero from './Components/Hero/Hero';
import Navbar from './Components/Navbar/Navbar';
import Features from './Components/Featuers/Features';
import About from './Components/About/About';
import Contact from './Components/Contact/Contact';
import Footer from './Components/Footer/Footer';
import Book from './Components/Books/Book';


function App() {
  return (
    <div>
      <Navbar />
      <Hero />
      <Features />
      <About />
      <Book />
      <Contact />
      <Footer />
    </div>
  );
}

export default App;
