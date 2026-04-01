import AppKit
import WebKit

class SVGRenderer {
    let webView: WKWebView
    private var currentSVG = ""
    private var isFlipped = false

    // Map CrabSpriteRenderer.Frame to SVG file names
    static let frameMap: [CrabSpriteRenderer.Frame: String] = [
        .idle:      "clawd-idle-follow",
        .walkA:     "clawd-idle-living",
        .walkB:     "clawd-idle-living",
        .blink:     "clawd-idle-follow",       // SVG has CSS blink built in
        .happy:     "clawd-happy",
        .surprised: "clawd-notification",
        .angry:     "clawd-error",
        .sad:       "clawd-idle-doze",
        .love:      "clawd-happy",
        .sleepy:    "clawd-sleeping",
        .smug:      "clawd-react-annoyed",
        .scared:    "clawd-notification",
        .dead:      "clawd-collapse-sleep",
        .wink:      "clawd-react-left",
    ]

    init() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.setValue(false, forKey: "drawsBackground")
    }

    func setFrame(_ frame: CrabSpriteRenderer.Frame) {
        guard let name = Self.frameMap[frame] else { return }
        loadSVG(named: name)
    }

    func setFlipped(_ flipped: Bool) {
        guard flipped != isFlipped else { return }
        isFlipped = flipped
        let scale = flipped ? "scaleX(-1)" : "scaleX(1)"
        webView.evaluateJavaScript("document.querySelector('svg').style.transform = '\(scale)';")
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

        let flipStyle = isFlipped ? "transform: scaleX(-1);" : ""
        let html = """
        <!DOCTYPE html>
        <html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; background: transparent; }
        svg { width: 100%; height: 100%; display: block; \(flipStyle) }
        </style></head>
        <body>\(svgContent)</body></html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}
