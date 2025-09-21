// ===== HTML GENERATOR MODULE =====
// This module contains the HTML generation logic that can be shared
// between the main application (index.js) and tests (app.test.js)

/**
 * Generates the complete HTML response for the Hello World app
 * @returns {string} Complete HTML document as a string
 */
function generateHTML() {
  // Get current server time - this is our main feature
  const currentTime = new Date().toLocaleString();
  
  // Return the complete HTML document
  return `
    <!DOCTYPE html>
    <html>
      <head>
        <title>Node.js Hello World - CI/CD Pipeline Test! 🚀</title>
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
          <h1>Hello World! 🚀</h1>
          <p style="background-color: #28a745; color: white; padding: 10px; border-radius: 5px; text-align: center; margin: 15px 0;">
            ✅ CI/CD Pipeline Test - Auto-deployed via GitHub Actions!
          </p>
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
}

// Export the function so other files can import and use it
module.exports = { generateHTML };
