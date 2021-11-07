//
//  LoginViewController.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import UIKit
import AuthenticationServices
import Alamofire
import SwiftyJSON
import KeychainAccess

class LoginViewController: UIViewController {

    let consts = Constants.shared
    var token = ""
    var session: ASWebAuthenticationSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let keychain = Keychain(service: consts.service)
//        if keychain["access_token"] != nil {
//            keychain["access_token"] = nil
//        }
    }
    
    // 取得したcodeを使ってアクセストークンを発行
    func getAccessToken(code: String!) {
        let url = URL(string: consts.baseUrl + "/access_tokens")!
        guard let code = code else { return }
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "ACCEPT": "application/json"
        ]
        let parameters: Parameters = [
            "client_id": consts.clientId,
            "client_secret": consts.clientSecret,
            "code": code
        ]
        print("CODE: \n\(code)")
        //Alamofireでリクエスト
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let token: String? = json["token"].string
                guard let accessToken = token else { return }
                self.token = accessToken
                //このアプリ用のキーチェーンを生成
                let keychain = Keychain(service: self.consts.service)
                //キーを設定して保存
                keychain["access_token"] = accessToken
                // 画面遷移
                self.transitionToTabBar()
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    @IBAction func loginQiita(_ sender: Any) {
        let keychain = Keychain(service: consts.service)
        if keychain["access_token"] != nil {
            token = keychain["access_token"]!
            transitionToTabBar()
        } else {
            let url = URL(string: consts.oAuthUrl + "?client_id=\(consts.clientId)&scope=\(consts.scopes)")!
            session = ASWebAuthenticationSession(url: url, callbackURLScheme: consts.callbackUrlScheme){(callback, error) in
                guard error == nil, let successURL = callback else { return }
                let queryItems = URLComponents(string: successURL.absoluteString)?.queryItems
                // codeの値だけ取り出す
                guard let code = queryItems?.filter({ $0.name == "code" }).first?.value else { return }
                self.getAccessToken(code: code)
            }
        }
        // デリゲート設定
        session?.presentationContextProvider = self
        // 認証セッションと通常のブラウザで閲覧情報やCookieを共有しないように設定
        session?.prefersEphemeralWebBrowserSession = true
        // セッションの開始(これがないと認証できない)
        session?.start()
    }
    
    func transitionToTabBar() {
        let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarC") as! UITabBarController
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil
        )
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

// ボタンを押したときにQiitaのログイン→認証の画面を開く
extension LoginViewController: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }

}
