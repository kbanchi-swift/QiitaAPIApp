//
//  PostViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class PostViewController: UIViewController {
    
    let consts = Constants.shared
    let okAlert = OkAlert()
    private var token = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        bodyTextView.layer.borderColor =  UIColor.placeholderText.cgColor
        bodyTextView.layer.borderWidth = 0.5
        bodyTextView.layer.cornerRadius = 5.0
        bodyTextView.layer.masksToBounds = true
        
        let keychain = Keychain(service: consts.service)
        guard let token = keychain["access_token"] else { return print("no token")}
        self.token = token
    }
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var isPrivateControl: UISegmentedControl!
    
    @IBAction func postArticle(_ sender: Any) {
        let article = createArticle()
        postRequest(article: article)
    }
    
    func postRequest(article: PostingArticle) {
        let url = URL(string: consts.baseUrl + "/items")!
        let parameters: Parameters = [
            "body": article.body,
            "private": article.isPrivate,
            "tags": [
                [
                    "name": article.tag,
                    "versions": []
                ]
            ],
            "title": article.title
        ]
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token)
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("Create Article : \(json)")
                self.okAlert.showOkAlert(title: "Created", messaage: "create article to Qiita", viewController: self)
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func createArticle() -> PostingArticle {
        if titleField.text == "" || tagsField.text == "" || bodyTextView.text == "" {
            okAlert.showOkAlert(title: "Empty Error", messaage: "please input all fields.", viewController: self)
        }
        var isPrivate: Bool!
        if isPrivateControl.selectedSegmentIndex == 0 {
//            isPrivate = false
            isPrivate = true
        } else {
            isPrivate = true
        }
        let article = PostingArticle(title: titleField.text!, tag: tagsField.text!, body: bodyTextView.text!, isPrivate: isPrivate )
        return article
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
