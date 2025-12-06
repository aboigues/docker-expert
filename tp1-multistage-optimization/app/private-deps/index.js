const express = require('express');
const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.json({
    status: 'success',
    message: 'App with private dependencies loaded successfully!',
    note: 'This app simulates using private npm packages'
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
