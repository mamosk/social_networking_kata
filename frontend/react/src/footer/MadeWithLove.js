import React from 'react';
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import '../fontawesome';
import './MadeWithLove.css'

const MadeWithLove = (props) => {
  return (
    <div class="item-footer">
      <span>made</span>
      <span aria-hidden="true">&nbsp;with&nbsp;<FontAwesomeIcon
        icon={['fas', 'heart']}
        transform="grow-2"
        fixedWidth
      /></span>
      <span>&nbsp;by&nbsp;</span>
      <a class="mamosk" href="https://github.com/mamosk">mamosk</a>
    </div>
  );
};

export default MadeWithLove;