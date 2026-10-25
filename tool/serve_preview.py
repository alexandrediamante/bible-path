"""Serve a release build locally under its GitHub Pages base path."""
import functools
import http.server
from pathlib import Path
from urllib.parse import urlsplit

WEB = Path(__file__).resolve().parent.parent / "build" / "web"

class PreviewHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/":
            self.send_response(302)
            self.send_header("Location", "/bible-path/")
            self.end_headers()
            return
        if not path.startswith("/bible-path/"):
            self.send_error(404)
            return
        self.path = self.path[len("/bible-path"):]
        super().do_GET()

if __name__ == "__main__":
    handler = functools.partial(PreviewHandler, directory=str(WEB))
    print("Preview: http://127.0.0.1:8765/bible-path/", flush=True)
    http.server.ThreadingHTTPServer(("127.0.0.1", 8765), handler).serve_forever()
