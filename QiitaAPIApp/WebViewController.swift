//
//  WebViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let articleUrl = URL(string: url)!
        let request = URLRequest(url: articleUrl)
        articleWebView.load(request)
    }
    
    @IBOutlet weak var articleWebView: WKWebView!
    var url: String!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
