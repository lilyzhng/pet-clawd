import AppKit
import WebKit

class SVGRenderer {
    let webView: WKWebView
    let displaySize: CGFloat = 80
    private var currentSVG = ""

    init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: displaySize, height: displaySize), configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
    }

    func loadSVG(named name: String) {
        guard name != currentSVG else { return }
        currentSVG = name
        guard let svgURL = Bundle.module.url(forResource: name, withExtension: "svg", subdirectory: "svg"),
              var svgContent = try? String(contentsOf: svgURL, encoding: .utf8) else { return }

        // Strip hardcoded width/height from SVG so it scales to container
        svgContent = svgContent.replacingOccurrences(
            of: #"(<svg[^>]*?)\s+width="[^"]*""#,
            with: "$1",
            options: .regularExpression
        )
        svgContent = svgContent.replacingOccurrences(
            of: #"(<svg[^>]*?)\s+height="[^"]*""#,
            with: "$1",
            options: .regularExpression
        )

        let s = Int(displaySize)
        let html = """
        <!DOCTYPE html>
        <html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; background: transparent; }
        svg { width: 100%; height: 100%; display: block; }
        </style></head>
        <body>\(svgContent)</body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
