//
//  UpdateAndDeleteViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class UpdateAndDeleteViewController: UIViewController {
    
    let consts = Constants.shared
    private var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        bodyTextView.layer.borderColor =  UIColor.placeholderText.cgColor
        bodyTextView.layer.borderWidth = 0.5
        bodyTextView.layer.cornerRadius = 5.0
        bodyTextView.layer.masksToBounds = true
        let keychain = Keychain(service: consts.service)
        guard let token = keychain["access_token"] else { return print("NO TOKEN")}
        self.token = token
        //記事固有のIDを受け取っているかどうか。
        if articleId == "" {
            return
        } else {
            loadArticle(articleId: articleId)
        }
    }
    
    private var article: UpdatingArticle!
    var articleId = ""
    let okAlert = OkAlert()
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBAction func updateArticle(_ sender: Any) {
        let article = createUpdatingArticle()
        updateAlert(article: article)
    }
    
    @IBAction func deleteArticle(_ sender: Any) {
        deleteAlert(articleId: articleId)
    }
    
    @IBAction func backToUser(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadArticle(articleId: String) {
        let url = URL(string: consts.baseUrl + "/items/" + articleId)!
        let headers :HTTPHeaders = [
            .authorization(bearerToken: token)
        ]
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let article = UpdatingArticle(
                    title: json["title"].string ?? "",
                    body: json["body"].string ?? ""
                )
                self.article = article
                self.titleField.text = self.article.title
                self.bodyTextView.text = self.article.body
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
    }
    
    func updateRequest(article: UpdatingArticle) {
        let url = URL(string: consts.baseUrl + "/items/" + articleId)!
        let parameters: Parameters = [
            "body": article.body,
            "title": article.title
        ]
        let headers :HTTPHeaders = [
            .authorization(bearerToken: token)
        ]
        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print("JSON: \n\(json)")
                self.okAlert.showOkAlert(title: "Updated", messaage: "update article to Qiita", viewController: self)
            case .failure(let err):
                self.okAlert.showOkAlert(title: "Error", messaage: err.localizedDescription, viewController: self)
                print(err.localizedDescription)
            }
        }
    }
    
    func createUpdatingArticle() -> UpdatingArticle {
        if titleField.text == "" || bodyTextView.text == "" {
            okAlert.showOkAlert(title: "Empty Error", messaage: "please input all fields.", viewController: self)
        }
        let article = UpdatingArticle(title: titleField.text!, body: bodyTextView.text!)
        return article
    }
    
    func deleteRequest(articleId: String){
        let url = URL(string: consts.baseUrl + "/items/" + articleId)!
        let headers :HTTPHeaders = [
            .authorization(bearerToken: token)
        ]
        AF.request(url, method: .delete, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.dismiss(animated: true, completion: nil)
                self.okAlert.showOkAlert(title: "Deleted", messaage: "delete article...", viewController: self)
                print(JSON(value))
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func deleteAlert(articleId: String) {
        let alert = UIAlertController(title: "Is that Ok to Delete??", message: "delete this article...", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.deleteRequest(articleId: articleId)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func updateAlert(article: UpdatingArticle) {
        let alert = UIAlertController(title: "Is that Ok to Update??", message: "update this article...", preferredStyle: .alert)
        let updateAction = UIAlertAction(title: "Update", style: .destructive) { action in
            self.updateRequest(article: article)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
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
