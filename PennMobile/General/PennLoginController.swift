//
//  PennLoginController.swift
//  PennMobile
//
//  Created by Josh Doman on 3/13/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation
import WebKit

class PennLoginController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    final private let loginURL = "https://weblogin.pennkey.upenn.edu/login"
    open var urlStr: String {
        return "https://weblogin.pennkey.upenn.edu/login"
    }
    
    open var pennkey: String?
    private var password: String?
    final private let testPennKey = "joshdo"
    
    final private var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: urlStr)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        navigationItem.title = "PennKey Login"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        
        pennkey = UserDefaults.standard.getPennKey()
        password = UserDefaults.standard.getPassword()
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        guard let url = request.url else {
            decisionHandler(.allow)
            return
        }
        
        let hasReferer = request.allHTTPHeaderFields?["Referer"] != nil
        if url.absoluteString == urlStr, hasReferer {
            // Webview has redirected to desired site.
            self.handleSuccessfulNavigation(webView, decidePolicy: navigationAction, decisionHandler: decisionHandler)
        } else {
            if url.absoluteString == loginURL {
                webView.evaluateJavaScript("document.getElementById('pennkey').value;") { (result, error) in
                    if let pennkey = result as? String {
                        webView.evaluateJavaScript("document.getElementById('password').value;") { (result, error) in
                            if let password = result as? String {
                                self.pennkey = pennkey
                                self.password = password
                            }
                            decisionHandler(.allow)
                        }
                    } else {
                        decisionHandler(.allow)
                    }
                }
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = webView.url else {
            return
        }
        
        if url.absoluteString == loginURL {
            guard let pennkey = pennkey, let password = password else { return }
            UserDefaults.standard.set(pennkey: pennkey)
            UserDefaults.standard.set(password: password)
            if !UserDBManager.shared.testRun && pennkey == self.testPennKey {
                self.dismiss(animated: true, completion: nil)
            }
            return
        } else if url.absoluteString.contains(loginURL) {
            self.autofillCredentials()
        }
    }
    
    func autofillCredentials() {
        guard let pennkey = pennkey, let password = password else { return }
        let script = """
        document.getElementById('pennkey').value = '\(pennkey)';
        document.getElementById('password').value = '\(password)';
        """
        webView.evaluateJavaScript(script) { (result, error) in
            if result == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: self.autofillCredentials)
            }
        }
    }
    
    @objc fileprivate func cancel(_ sender: Any) {
        _ = self.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Decide Policy Upon Completed Navigation
    // Note: This should be overridden when extending this class
    func handleSuccessfulNavigation(
        _ webView: WKWebView,
        decidePolicy navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        self.dismiss(animated: true, completion: nil)
        decisionHandler(.cancel)
    }
}

