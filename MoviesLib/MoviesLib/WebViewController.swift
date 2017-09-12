//
//  WebViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 11/09/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    @IBAction func clouse(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func runJS(_ sender: Any) {
        
        webView.stringByEvaluatingJavaScript(from: "alert( 'aberto ')")
    }
    
    var url: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.startAnimating()
        
        webView.delegate = self
        
        
        let webUrl = URL(string : url)!
        let request = URLRequest(url: webUrl)
        webView.loadRequest(request)
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
}

extension WebViewController: UIWebViewDelegate{
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loading.stopAnimating()
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let absoluteString = request.url!.absoluteString
        if absoluteString.range(of: "facebook") != nil{
        
            
            let alert = UIAlertController(title: "ERRO",
                                          message: "Facebook na lista negra ",
                                          preferredStyle: .actionSheet)
            
            let okAction = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                print("User CLICK")
            })
            
            
            let cancelAction = UIAlertAction(title: "Cancela", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
            
            
            return false
        }
        
        
        return true
    }

}
