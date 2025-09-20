const http = require('http');
// Import our shared HTML generator
const { generateHTML } = require('./lib/htmlGenerator');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  
  // Use the shared HTML generator function
  const html = generateHTML();
  res.end(html);
});

server.listen(port, () => {
  console.log(`Server running on http://localhost:${port}/`);
});