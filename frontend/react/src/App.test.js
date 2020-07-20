import React from 'react';
import { render } from '@testing-library/react';
import App from './App';

test('renders menu', () => {
  const { getByText } = render(<App />);
  expect(getByText(/specs/i)).toBeInTheDocument();
  expect(getByText(/gateway/i)).toBeInTheDocument();
  expect(getByText(/timelines/i)).toBeInTheDocument();
  expect(getByText(/followers/i)).toBeInTheDocument();
  expect(getByText(/code/i)).toBeInTheDocument();
});
