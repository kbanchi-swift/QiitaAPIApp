//
//  SearchTagViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainAccess

class SearchTagViewController: UIViewController {
    
    let consts = Constants.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        articleTableView.dataSource = self
        tagSearchBar.delegate = self
        articleTableView.delegate = self
    }
    
    var articles: [Article] = []
    
    @IBOutlet weak var tagSearchBar: UISearchBar!
    @IBOutlet weak var articleTableView: UITableView!
    
    func loadArticles(tag: String) {
        let url = URL(string: consts.baseUrl + "/tags/\(tag)/items")!
        let keychain = Keychain(service: consts.service)
        guard let token = keychain["access_token"] else { return }
        let headers: HTTPHeaders = [
            .authorization(bearerToken: token)
        ]
        AF.request(url, method: .get, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                self.articles = []
                let json = JSON(value).arrayValue
                for article in json {
                    self.articles.append(
                        Article(
                            title: article["title"].string ?? "",
                            urlString: article["url"].string ?? ""
                        )
                    )
                }
                OkAlert().showOkAlert(title: "Search Complete", messaage: "complete search articles.", viewController: self)
                self.articleTableView.reloadData()
            case .failure(let err):
                print(err.localizedDescription)
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

extension SearchTagViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = articles[indexPath.row].title
        cell.contentConfiguration = content
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension SearchTagViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let webVC = self.storyboard?.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        let article = articles[indexPath.row]
        webVC.url = article.urlString
        webVC.title = article.title
        navigationController?.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(webVC, animated: true)
    }
    
}

extension SearchTagViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.searchTextField.text else { return print("no text") }
        if searchText != "" {
            loadArticles(tag: searchText)
            searchBar.endEditing(true)
        }
    }
    
}
