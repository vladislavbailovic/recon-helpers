import sys
import socketserver
from http.server import SimpleHTTPRequestHandler
from argparse import ArgumentParser

class ServeOnce(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(self.server._expected.encode("utf-8"))
        sys.exit()

def main():
    parser = ArgumentParser()
    parser.add_argument("script", nargs='?', type=str, help="File to serve")
    parser.add_argument("--port", type=int, help="Port to use")
    args = parser.parse_args()

    port = args.port if args.port else 8080
    script = []
    if args.script:
        with open(args.script, "r") as fp:
            script = fp.readlines()
    else:
        for line in sys.stdin:
            script.append(line.rstrip())

    with socketserver.TCPServer(("", port), ServeOnce) as httpd:
        httpd._expected = "\n".join(script)
        httpd.serve_forever()

if __name__ == "__main__":
    main()
