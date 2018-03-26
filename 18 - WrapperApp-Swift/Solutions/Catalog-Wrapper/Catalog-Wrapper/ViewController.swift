import UIKit
import WebKit


class ViewController: UIViewController {
    
    var webView: WKWebView!
    
    let indexURL = URL(string: "http://localhost:5000")!
    var request: URLRequest
    
    required init?(coder aDecoder: NSCoder) {
        request = URLRequest(url: indexURL)
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inject some javascript to be run when the page is loaded.
        let userContentController = WKUserContentController()
        let source = "document.body.style.background = '#eee';"
        let userScript = WKUserScript(source: source, 
                                      injectionTime: .atDocumentEnd,
                                      forMainFrameOnly: true)
        userContentController.addUserScript(userScript)
        
        // Advertise that we support receiving messages.  Post them in JavaScript via:
        // window.webkit.messageHandlers.catalog.postMessage
        userContentController.add(self, name: "catalog")
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptEnabled = true
        configuration.userContentController = userContentController
        
        // Make the web view
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.navigationDelegate = self
        
        // Can't create these in IB, so add to the VC's container view and snug it to the edges
        webView.autoresizingMask = [ .flexibleHeight, .flexibleWidth ]
        
        view.addSubview(webView)
        webView.load(request)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!, 
                 withError error: Error) {
        
        let complaint = "Could not load \(indexURL).  Have you run.py the web service?  Error: \"\(error.localizedDescription)\""
        
        let alert = UIAlertController(title: "Could not load page",
                                      message: complaint,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", 
                                     style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title") { (result, error) -> Void in
            let pageTitle = result as? String ?? "Catalog"
            print("we just loaded \(pageTitle)!")
            self.navigationItem.title = pageTitle
        }
    }
    
    func webView(_ webView: WKWebView, 
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy)
        -> Void) {
        
        if navigationAction.navigationType == .linkActivated {
            let vc = storyboard?.instantiateViewController(withIdentifier: "WebViewController") as! ViewController
            
            vc.request = navigationAction.request
            show(vc, sender: self)
            
            decisionHandler(.cancel)
            
        } else {
            decisionHandler(.allow)
        }
    }
    
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard let payload = message.body as? [String: Any],
            let productId = payload["productId"] else {
                return
        }
        print("TODO: Add product \(productId) to list of interesting products")
    }
}

