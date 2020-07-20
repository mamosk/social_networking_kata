import React from 'react';
import Kata from './header/Kata';
import Dummy from './menu/Dummy';
import Item from './menu/Item';
import MadeWithLove from './footer/MadeWithLove';
import Ninja from './footer/Ninja';
import './App.css';

const menuItems = [
  // SPECS
  {
    icon: ['fas', 'book'],
    links: [
      {
        href: 'https://github.com/xpeppers/social_networking_kata/blob/master/README.md',
        text: 'specs'
      },
    ]
  },
  // GATEWAY
  {
    icon: ['fas', 'map-signs'],
    links: [
      {
        href: 'http://localhost:11881/',
        text: 'gateway'
      },
    ]
  },
  // TIMELINES (API+DB)
  {
    icon: ['fas', 'stream'],
    links: [
      {
        href: 'http://localhost:11888/',
        text: 'timelines'
      },
      {
        href: 'http://localhost:18888/sources/0/chronograf/data-explorer?query=SELECT%20%22post%22%20FROM%20%22kata%22.%22autogen%22.%22timeline%22%20WHERE%20time%20%3E%20%3AdashboardTime%3A%20AND%20time%20%3C%20%3AupperDashboardTime%3A%20GROUP%20BY%20%22user%22',
        text: 'db'
      },
    ]
  },
  // FOLLOWERS (API+DB)
  {
    icon: ['fas', 'user-friends'],
    links: [
      {
        href: 'http://localhost:18080/api/v1/users',
        text: 'followers'
      },
      {
        href: 'http://localhost:15050/',
        text: 'db'
      },
    ]
  },
  // GITHUB
  {
    icon: ['fas', 'code'],
    links: [
      {
        href: 'https://github.com/mamosk/social-network-kata/',
        text: 'code'
      },
    ]
  },
];
function App(props) {
  const items = menuItems.map((item) =>
    <Item icon={item.icon} links={item.links} />
  );
  return (
    // App is a css grid container
    <div className='App'>
      <Kata kata='Social Network' />
      <Dummy />
      {items}
      <MadeWithLove />
      <Ninja />
    </div>
  );
}

export default App;