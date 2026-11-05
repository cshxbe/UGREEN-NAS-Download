import http.server,ssl,sys,json,base64
class Handler(http.server.BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path=='/redirect': self.send_response(302);self.send_header('Location','https://127.0.0.1:18443/');self.end_headers();return
  self.send_response(200);self.send_header('Content-Type','application/json');self.end_headers();self.wfile.write(b'{"code":200}')
 def do_POST(self):
  body=self.rfile.read(int(self.headers.get('Content-Length','0')))
  self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('X-Rsa-Token','test-public-key');self.end_headers();self.wfile.write(json.dumps({'base64':base64.b64encode(body).decode()}).encode() if self.path=='/binary' else body)
 def log_message(self,*args): pass
s=http.server.HTTPServer(('127.0.0.1',18443),Handler)
c=ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER);c.load_cert_chain(sys.argv[1],sys.argv[2]);s.socket=c.wrap_socket(s.socket,server_side=True);s.serve_forever()
