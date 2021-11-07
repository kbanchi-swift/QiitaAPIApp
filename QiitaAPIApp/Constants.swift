//
//  Constants.swift
//  QiitaAPIApp
//
//  Created by 伴地慶介 on 2021/11/07.
//

import Foundation

struct Constants {
    static let shared = Constants()
    private init() {}
    
    // ClientID and ClientSecret
    let clientId = ""
    let clientSecret = ""
    
    // API URL
    let baseUrl = "https://qiita.com/api/v2"
    
    // OAuth URL
    let oAuthUrl = "https://qiita.com/api/v2/oauth/authorize"
    
    // authority type that you want
    let scopes = "read_qiita+write_qiita"
    
    // callback URL scheme
    let callbackUrlScheme = "qiita-api-oauth"
    
    // service
    let service = "QiitaApiApp"
}
