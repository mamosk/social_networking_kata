import React from 'react';
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import '../fontawesome';
import './menu.css';

const Item = (props) => {
  return (
    <div class="item">
      <FontAwesomeIcon
        aria-hidden="true"
        icon={['fas', 'book']}
        transform="grow-10"
        fixedWidth
      />
      <p>
        <a href={props.href}>
          <span class="slash" aria-hidden="true">/</span>
          <span class="link">{props.text}</span>
        </a>
      </p>
    </div>
  );
};

export default Item;