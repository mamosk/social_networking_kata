import { v4 as uuidv4 } from 'uuid';
import React from 'react';
import Kata from './header/Kata';
import Item from './menu/Item';
import MadeWithLove from './footer/MadeWithLove';
import Ninja from './footer/Ninja';
import './App.css';

const menu = require('./menu/menu').map((item) =>
  <Item
    key={item.icon?.join('-') || uuidv4()}
    icon={item.icon}
    links={item.links}
  />
);
function App() {
  return (
    // App is a css grid container
    <div className='App'>
      <Kata kata='Social Network' />
      {menu}
      <MadeWithLove />
      <Ninja />
    </div>
  );
}

export default App;