import React from 'react';
import Kata from './header/Kata';
import Dummy from './menu/Dummy';
import Item from './menu/Item';
import MadeWithLove from './footer/MadeWithLove';
import Ninja from './footer/Ninja';
import './App.css';
function App(props) {
  return (
    // App is a css grid container
    <div className="App">
      <Kata kata="Social Network" />
      <Dummy />
      {/* <Item
        href="https://github.com/xpeppers/social_networking_kata/blob/master/README.md"
        text="specs"
      /> */}
      <MadeWithLove />
      <Ninja />
    </div>
  );
}

export default App;