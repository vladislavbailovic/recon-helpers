import sys
import socketserver
from http.server import SimpleHTTPRequestHandler
from argparse import ArgumentParser

class ServeOnce(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        self.wfile.write(ServeOnce._expected.encode("utf-8"))
        sys.exit()

def main():
    parser = ArgumentParser()
    parser.add_argument("script", type=str, help="File to serve")
    parser.add_argument("--port", type=int, help="Port to use")

    args = parser.parse_args()
    if not args.script:
        print("Missing script")
        sys.exit(1)

    port = args.port if args.port else 8080
    script = ""
    with open(args.script, "r") as fp:
        script = fp.readlines()

    with socketserver.TCPServer(("", port), ServeOnce) as httpd:
        ServeOnce._expected = "\n".join(script)
        httpd.serve_forever()

if __name__ == "__main__":
    main()
