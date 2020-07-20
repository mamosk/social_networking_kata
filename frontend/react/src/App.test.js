import React from 'react';
import { render } from '@testing-library/react';
import App from './App';

test('renders learn react link', () => {
  const { getByText } = render(<App />);
  const links =[/specs/i, /gateway/i, /timelines/i, /followers/i, /code/i, /db/i];
  links.map((link) => getByText(link))
    .forEach((linkElement) => expect(linkElement).toBeInTheDocument());
});
