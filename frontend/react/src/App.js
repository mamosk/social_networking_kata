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
      <Kata themeColor={props.themeColor} kata="Social Network" />
      <Dummy />
      {/* <Item
        themeColor={props.themeColor}
        href="https://github.com/xpeppers/social_networking_kata/blob/master/README.md"
        text="specs"
      /> */}
      <MadeWithLove themeColor={props.themeColor}/>
      <Ninja />
    </div>
  );
}

export default App;