const http = require('http');
const port = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  
  const currentTime = new Date().toLocaleString();
  
  const msg = `
    <!DOCTYPE html>
    <html>
      <head>
        <title>Node.js Hello World</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
          }
          .container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            max-width: 400px;
            text-align: center;
          }
          h1 {
            color: #333;
            margin-bottom: 20px;
          }
          .time-box {
            background-color: #e7f3ff;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
          }
          .time-label {
            color: #666;
            font-size: 14px;
          }
          .time-value {
            color: #333;
            font-size: 18px;
            font-weight: bold;
            margin-top: 5px;
          }
          button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
          }
          button:hover {
            background-color: #45a049;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Hello World!</h1>
          <div class="time-box">
            <div class="time-label">Current Server Time:</div>
            <div class="time-value">${currentTime}</div>
          </div>
          <button onclick="location.reload()">
            Refresh Time
          </button>
        </div>
      </body>
    </html>
  `;
  
  res.end(msg);
});

server.listen(port, () => {
  console.log(`Server running on http://localhost:${port}/`);
});