//
//  UserViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess
import Kingfisher

class UserViewController: UIViewController {

    let sectionTitles = ["自分の投稿:"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        userTableView.dataSource = self
        userTableView.delegate = self
        // ユーザ画像の設定
        userImageView.layer.cornerRadius = userImageView.layer.frame.width / 2.0
        userImageView.layer.borderWidth = 2.0
        userImageView.layer.borderColor = UIColor.green.cgColor
        userImageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserInfoFromQiita()
    }
    
    let consts = Constants.shared
    var myArticles: [MyArticle] = []
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var otherNum: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userTableView: UITableView!
   
    func getUserInfoFromQiita() {
        // プロフィール情報取得
        // キーチェーンからアクセストークンを取得
        let keychain = Keychain(service: consts.service)
        guard let accessToken = keychain["access_token"] else { return print("no token")}
        
        // リクエストURLの生成
        let url = URL(string: consts.baseUrl + "/authenticated_user")!
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken)
        ]
        // Alamofireでリクエスト
        AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON {response in
            switch response.result {
                //successの時
            case .success(let value):
                // SwiftyJSONでDecode
                let json = JSON(value)
                print(json)
                // User型のオブジェクトを作成
                let user = User(
                    description: json["description"].string ?? "",
                    followeesCount: json["followees_count"].int!,
                    followersCount: json["followers_count"].int!,
                    id: json["id"].string ?? "",
                    itemsCount: json["items_count"].int!,
                    name: json["name"].string ?? "",
                    profileImageUrl: json["profile_image_url"].string ?? ""
                )
                // 作成したUser型オブジェクトを設定
                self.setUser(user: user)
                //failureの時
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        // 自分の記事情報取得
        // 記事取得URLの生成
        let itemUrl = URL(string: consts.baseUrl + "/authenticated_user/items")!
        // Alamofireでリクエスト
        AF.request(itemUrl, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
                // success
            case .success(let value):
                self.myArticles = []
                let json = JSON(value).arrayValue
                // print(json)
                for myArticle in json {
                    let article = MyArticle(
                        title: myArticle["title"].string ?? "",
                        url: myArticle["url"].string ?? "",
                        articleId: myArticle["id"].string ?? "",
                        isPrivate: myArticle["private"].bool!
                    )
                    self.myArticles.append(article)
                }
                // print(self.myArticles)
                self.userTableView.reloadData()
                // fail
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func setUser(user: User) {
        // プロフィール画像のURLを生成
        let imageUrl = URL(string: user.profileImageUrl)!
        // kingfisherで画像を取得してimageViewに設定
        userImageView.kf.setImage(with: imageUrl)
        // Labelに設定
        displayName.text = user.name
        accountName.text = "@" + user.id
        otherNum.text = "投稿: \(user.itemsCount)  フォロー: \(user.followeesCount)  フォロワー: \(user.followersCount)"
        descriptionLabel.text = user.description
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

extension UserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyArticleCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        if myArticles[indexPath.row].isPrivate {
            content.text = "[限定共有]" + myArticles[indexPath.row].title
        } else {
            content.text = myArticles[indexPath.row].title
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
}

extension UserViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let updateAndDeleteVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateAndDeleteVC") as! UpdateAndDeleteViewController
        updateAndDeleteVC.articleId = myArticles[indexPath.row].articleId
        updateAndDeleteVC.modalPresentationStyle = .fullScreen
        present(updateAndDeleteVC, animated: true, completion: nil)
    }
    
}
