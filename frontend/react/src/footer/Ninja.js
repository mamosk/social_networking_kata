import React from 'react';
import './Ninja.css';

const Ninja = (props) => {
  return (
    <div class='logo'>
      <img src={`${process.env.PUBLIC_URL}/logo512.png`} alt='There should be a ninja here!' />
    </div>
  );
};

export default Ninja;