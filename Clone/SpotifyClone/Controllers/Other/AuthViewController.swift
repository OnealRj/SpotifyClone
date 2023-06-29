//
//  AuthViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    // A private variable of WKWebView type. WKWebView is used to present
    // an embedded view that can load and display web content.
    private let webView: WKWebView = {
        // Create an instance of WKWebpagePreferences to allow JavaScript in the webpage.
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        
        // Create a WKWebViewConfiguration instance and set the default webpage preferences.
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        
        // Instantiate WKWebView with the above configuration.
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    
    public var completionHandeler:((Bool) -> Void)? 


    // This function is called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the title of the navigation bar in this view controller.
        self.title = "Sign In"
        
        // Set the background color of the view.
        self.view.backgroundColor = .systemBackground
        
        // Add the webView as a subview of the main view.
        self.webView.navigationDelegate = self
        self.view.addSubview(self.webView)
        guard let url = AuthManager.shared.signInURL else
        {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    // This method is called to notify the view controller that its view has just laid out its subviews.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Set the frame of the webView to match the bounds of the view.
        self.webView.frame = self.view.bounds
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        guard let url = webView.url else
        {
            return
        }
        let component = URLComponents(string: url.absoluteString)
        //exchange the code for an access token
        guard let code = component?.queryItems?.first(where: { $0.name == "code"})?.value else{
            return
        }
        print("Code: \(code)")
        AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completionHandeler?(success)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
