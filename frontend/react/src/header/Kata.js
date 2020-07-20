import React from 'react';
import './Kata.css';

const Kata = (props) => {
  return (
    <div class="kata">
      <p>
        <span class="kata-title" style={{ color: props.themeColor }}>{props.kata}</span>
        <span class="kata-title">&nbsp;kata</span>
      </p>
    </div>
  );
};

export default Kata;