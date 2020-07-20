import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import '../fontawesome';
import './menu.css';

const Item = (props) => {
  const links = props.links.map((link) =>
    <a href={link.href}>
      <span class='slash' aria-hidden='true'> /</span>
      <span class='link'>{link.text}</span>
    </a>
  );
  return (
    <div class='item'>
      <FontAwesomeIcon
        aria-hidden='true'
        icon={props.icon}
        transform='grow-10'
        fixedWidth
      />
      <p>
        {links}
      </p>
    </div>
  );
};

export default Item;