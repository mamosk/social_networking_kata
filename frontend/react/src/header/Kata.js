import React from 'react';
import './Kata.css';

const Kata = (props) => {
  return (
    <div className='kata'>
      <p>
        <span className='kata-title kata-name'>{props.kata}</span>
        <span className='kata-title'>&nbsp;kata</span>
      </p>
    </div>
  );
};

export default Kata;