FROM python:3.12-slim

WORKDIR /app

# Copy the static files (install.sh, version.json, README.md).
COPY install.sh version.json README.md ./

# Simple static file server using Python's http.server.
# Render's health check hits /health — we map that to a 200 JSON response.
RUN printf '#!/usr/bin/env python3\nimport http.server, socketserver, json, os\n\nclass H(http.server.BaseHTTPRequestHandler):\n    def do_GET(self):\n        if self.path == "/health":\n            self.send_response(200); self.send_header("Content-Type","application/json"); self.end_headers()\n            self.wfile.write(json.dumps({"status":"ok","version":"1.0.0","service":"shahadath-serve"}).encode()); return\n        path = self.path.lstrip("/") or "README.md"\n        if not os.path.exists(path):\n            self.send_response(404); self.end_headers(); self.wfile.write(b"not found"); return\n        self.send_response(200)\n        if path.endswith(".sh"):\n            self.send_header("Content-Type","text/x-shellscript")\n        elif path.endswith(".json"):\n            self.send_header("Content-Type","application/json")\n        else:\n            self.send_header("Content-Type","text/plain")\n        self.end_headers()\n        with open(path,"rb") as f: self.wfile.write(f.read())\n    def log_message(self, *a): pass\n\nwith socketserver.TCPServer(("0.0.0.0", int(os.environ.get("PORT","10000"))), H) as s:\n    s.serve_forever()\n' > /app/server.py

EXPOSE 10000

CMD ["python3", "/app/server.py"]
