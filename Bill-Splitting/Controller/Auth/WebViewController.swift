//
//  WebViewController.swift
//  Bill-Splitting
//
//  Created by 雷翎 on 2022/5/9.
//

import UIKit
import WebKit

enum PolicyUrl {
    case privacy
    case eula
    
    var url: String {
        switch self {
        case .privacy:
            return "https://pages.flycricket.io/wecount/privacy.html"
        case .eula:
            return  "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        }
    }
}

class WebViewController: UIViewController {
    
    var webView: WKWebView?
    
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadURL(urlString: url ?? PolicyUrl.eula.url)
        
    }
    
    private func loadURL(urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            let request = URLRequest(url: url)
            webView = WKWebView(frame: self.view.frame)
            if let mWebView = webView {
                mWebView.navigationDelegate = self
                mWebView.load(request)
                self.view.addSubview(mWebView)
                self.view.sendSubviewToBack(mWebView)
            }
        }
    }
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
}
