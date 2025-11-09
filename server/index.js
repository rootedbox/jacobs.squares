const express = require('express');
const path = require('path');

const app = express();
const PORT = 3000;

// Serve static files from the Ember build
const distPath = path.join(__dirname, '../frontend/dist');
app.use(express.static(distPath));

// Catch-all route to serve index.html for Ember routing
app.get('*', (req, res) => {
  res.sendFile(path.join(distPath, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Jacobs Squares server running on http://localhost:${PORT}`);
  console.log('All processing is now done in the browser! 🎉');
});
