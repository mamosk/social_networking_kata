import React from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import '../fontawesome';
import './menu.css';

const Item = (props) => {
  const links = props.links?.map((link) =>
    <a href={link.href}>
      <span className='slash' aria-hidden='true'> /</span>
      <span className='link'>{link.text}</span>
    </a>
  );
  let content;
  if (Array.isArray(links) && links.length) {
    content = (
      <>
        <div className='item-square'>
          <FontAwesomeIcon
            aria-hidden='true'
            icon={props.icon}
            transform='grow-10 down-19'
            fixedWidth
          />
        </div>
        <p>
          {links}
        </p>
      </>
    );
  }
  ;
  return (
    <div className='item'>
      {content}
    </div>
  );
};

export default Item;