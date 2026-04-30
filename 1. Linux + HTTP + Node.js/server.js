const http = require('http');
const os = require('os');
const fs = require('fs');
const path = require('path');

const PORT = 3000;

const server = http.createServer((req, res) => {
  if (req.url === '/' && req.method === 'GET') {
    const osInfo = {
      type: os.type(),
      hostname: os.hostname(),
      cpu_count: os.cpus().length,
      total_memory_mb: Math.floor(os.totalmem() / (1024 * 1024)),
      uptime_hours: Number((os.uptime() / 3600).toFixed(2))
    };

    const accept = req.headers.accept || '';
    if (accept.includes('text/html')) {
      const htmlPath = path.join(__dirname, 'assets', 'week1.html');
      fs.readFile(htmlPath, 'utf8', (err, data) => {
        if (err) {
          res.writeHead(500, { 'Content-Type': 'text/plain; charset=utf-8' });
          res.end('Internal Server Error: Cannot read HTML file.');
          return;
        }
        
        const renderedHtml = data
          .replace('{{type}}', osInfo.type)
          .replace('{{hostname}}', osInfo.hostname)
          .replace('{{cpu_num}}', osInfo.cpu_count)
          .replace('{{total_mem}}', osInfo.total_memory_mb + ' MB')
          .replace('{{uptime_hours}}', osInfo.uptime_hours);
          
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(renderedHtml);
      });
      return;
    }

    // JSON response for all other clients (default)
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(osInfo, null, 2));

  } else if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify({ status: 'ok' }));

  } else if (req.url === '/api/info' && req.method === 'GET') {
    const osInfo = {
      type: os.type(),
      hostname: os.hostname(),
      cpu_count: os.cpus().length,
      total_memory_mb: Math.floor(os.totalmem() / (1024 * 1024)),
      uptime_hours: Number((os.uptime() / 3600).toFixed(2))
    };
    res.writeHead(200, { 'Content-Type': 'application/json; charset=utf-8' });
    res.end(JSON.stringify(osInfo, null, 2));
    
  } else {
    res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('Not Found');
  }
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
