//
//  AuthManager.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import Foundation
final class AuthManager
{
    static let shared = AuthManager()
    
    private init() {}
    
    private var refreshingToken: Bool = false
    private var onRefreshBlocks = [((String) ->Void)]()
    
    struct Constants
    {
        static let clientID: String = "2ddbdaa3218f4ff99f8f4bc0b881bbc2"
        static let clientSecret: String = "0a2031820e2545618332382ce99609f6"
        static let tokenAPIURL:String = "https://accounts.spotify.com/api/token"
        static let redirectURI:String = "https://iosacademy.io"
        static let scopes:String = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-read-private%20user-follow-read%20user-library-read%20user-read-email%20playlist-modify-public%20playlist-modify-private%20user-library-modify"
    }
    
    public var signInURL: URL? = {
        let scopes = Constants.scopes
        let base = "https://accounts.spotify.com/authorize"
        let redirectURI = Constants.redirectURI
        let string = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }()
    
    var isSignedIn: Bool
    {
        return self.accessToken != nil
    }
    
    private var accessToken: String?
    {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String?
    {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date?
    {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool
    {
        guard let expDate = self.tokenExpirationDate else
        {
            return false
        }
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expDate
    }
    
    public func exchangeCodeForToken(code: String, completion: @escaping((Bool) -> Void))
    {
        // Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else
        {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [ URLQueryItem(name: "grant_type", value: "authorization_code"),
                                  URLQueryItem(name: "code", value: code),
                                  URLQueryItem(name: "redirect_uri", value: Constants.redirectURI)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        
        let basictoken = Constants.clientID+":"+Constants.clientSecret
        let data = basictoken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else
        {
            print("Failure to get BASE64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data,_,error) in
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            do{
                //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            }
            catch{
                print("ERROR: \(error.localizedDescription)")
                completion(false)
            }
        }
        task.resume()
    }
    
    
    /// supplies valid token to be used with API calls
    public func withValidToken(completion: @escaping (String) -> Void)
    {
        guard !refreshingToken else
        {
            self.onRefreshBlocks.append(completion)
            return
        }
        if self.shouldRefreshToken
        {
            self.refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success
                {
                    completion(token)
                }
            }
        }
        else if let token = self.accessToken
        {
            completion(token)
        }
    }
    
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?)
    {
        guard !refreshingToken else
        {
            return
        }
        guard shouldRefreshToken else
        {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else
        {
            return
        }
        // Refresh Token
        guard let url = URL(string: Constants.tokenAPIURL) else
        {
            return
        }
        self.refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                  URLQueryItem(name: "refresh_token", value: refreshToken)]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basictoken = Constants.clientID+":"+Constants.clientSecret
        let data = basictoken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else
        {
            print("Failure to get BASE64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request){ [weak self] (data,_,error) in
            self?.refreshingToken = false
            guard let data = data, error == nil else{
                completion?(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            }
            catch{
                print("ERROR: \(error.localizedDescription)")
                completion?(false)
            }
        }
        task.resume()
    }
    private func cacheToken(result: AuthResponse)
    {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token
        {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    public func signOut(completion: (Bool) -> Void)
    {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        completion(true)
        
    }
}
