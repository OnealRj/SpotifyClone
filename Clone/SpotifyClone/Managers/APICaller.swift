//
//  APICaller.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import Foundation

final class APICaller
{
    enum HTTPMethod: String
    {
        case GET
        case POST
        case DELETE
        case PUT
    }
    enum APIError: Error
    {
        case failedToGetData
    }
    struct Constants
    {
        static let baseAPIUrl = "https://api.spotify.com/v1"
    }
    
    static let shared = APICaller()
    
    private init() {}
    
    // function creates a URL request with a valid token
    // It takes in a URL, HTTP Method (GET, POST, etc), and a completion handler that takes a URLRequest as a parameter
    private func createRequest(with url: URL?,
                               type:HTTPMethod,
                               completion: @escaping(URLRequest) -> Void)
    {
        // Access the shared instance of AuthManager to get a valid token
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else
            {
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
    }
    
    
    // MARK: - Albums
    public func getAlbumDetails(for album: Album, completion: @escaping ((Result<AlbumDetailsReponse, Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/albums/\(album.id)"),
                           type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest)
            {
                (data, _, error) in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(AlbumDetailsReponse.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
        
    }
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album], Error>) -> Void)
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/me/albums"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                    
                }
                do
                {
                    let result = try JSONDecoder().decode(LibraryAlbumReponse.self, from: data)
                    let albums = result.items.compactMap { $0.album }
                    completion(.success(albums))
                }
                catch
                {
                    print(error.localizedDescription)
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
        
    }
    
    public func addAlbumToSavedLibrary(album: Album, completion: @escaping ((Bool) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/me/albums?ids=\(album.id)"), type: .PUT) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let code = (response as? HTTPURLResponse)?.statusCode,
                      error == nil else {
                    completion(false)
                    return
                }
                print(code)
                completion(code == 200)
            }
            task.resume()
            
        }
        
    }

    // MARK: - UserProfile
    public func getCurrentUserProfile(completion: @escaping ((Result<UserProfile, Error>) -> Void))
    {
        self.createRequest(with: URL(string:Constants.baseAPIUrl + "/me"), type: .GET)
        {
            baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest)
            {
                (data, _, error) in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - New Releases
    
    public func getNewReleases(completion: @escaping ((Result<NewReleasesRespose, Error>)) -> Void)
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/browse/new-releases?limit?limit=20"), type: .GET)
        {
            baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) {
                (data,_,error) in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(NewReleasesRespose.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
        
    }
    // MARK: - Genres
    
    public func getUserRecommendedGenres(completion: @escaping ((Result<RecommendedGenreResponse, Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/recommendations/available-genre-seeds"), type: .GET)
        {
            baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data,_,error) in
                guard let data = data, error == nil else {
                    return completion(.failure(APIError.failedToGetData))
                }
                do
                {
                    let result = try JSONDecoder().decode(RecommendedGenreResponse.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    // MARK: - Playlists
    public func getPlaylistDetails(for playlist: PlaylistItem, completion: @escaping ((Result<PlaylistDetailResponse, Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/playlists/\(playlist.id)"),
                           type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest)
            {
                (data, _, error) in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(PlaylistDetailResponse.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                    print(error.localizedDescription)
                }
            }
            task.resume()
        }
        
    }
    public func getUserRecommendations(genres:Set<String>, completion: @escaping ((Result<RecommendationsReponse, Error>) -> Void))
    {
        // needed seeded values before you can call this
        let seeds = genres.joined(separator: ",")
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET)
        {
            baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data,_,error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(RecommendationsReponse.self, from: data)
                    completion(.success(result))
                    
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func getCurrentUserPlaylists(completion: @escaping((Result<[PlaylistItem], Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/me/playlists/?limit=50"),
                           type: .GET) {
            baseRequest in
                let task = URLSession.shared.dataTask(with: baseRequest)
                {
                    (data,_,error) in
                    guard let data = data, error == nil else{
                        completion(.failure(APIError.failedToGetData))
                        return
                    }
                    do
                    {
                        //let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        let result = try JSONDecoder().decode(LibraryPlaylistsReponse.self, from: data)
                        completion(.success(result.items))
                    }
                    catch
                    {
                        completion(.failure(APIError.failedToGetData))
                    }
                }
            task.resume()
        }
    }
    
    public func createPlaylists(with name: String, completion: @escaping((Bool) -> Void)) {
        getCurrentUserProfile{ [weak self] result in
            switch result {
            case .success(let user):
                let urlString = Constants.baseAPIUrl + "/users/\(user.id)/playlists"
                self?.createRequest(with: URL(string: urlString), type: .POST) { baseRequest in
                    var request = baseRequest
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        do {
                            let result = try JSONSerialization.jsonObject(with: data)
                            if let response = result as? [String:Any], response["id"] as? String != nil
                            {
                                print("completed")
                                completion(true)
                            }
                            else
                            {
                                print("failed to get ID")
                            }
                        } catch {
                            print("JSON Parsing Error: \(error.localizedDescription)")
                            completion(false)
                        }
                    }
                    task.resume()
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    public func addTrackToPlaylist(track: AudioTrack,
                                   playlist: PlaylistItem,
                                   completion: @escaping (Bool) -> Void)
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/playlists/\(playlist.id)/tracks"),
                           type: .POST) { baseRequest in
            
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let json = [
                "uris": [
                    "spotify:track:\(track.id)"
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            let task = URLSession.shared.dataTask(with: request) { data, _ , error in
                guard let data = data, error == nil else
                {
                    completion(false)
                    return
                }
                do
                {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let repsonse = result as? [String: Any],
                       repsonse["snapshot_id"] as? String != nil
                    {
                        completion(true)
                    }
                }
                catch
                {
                    completion(false)
                }
            }
            task.resume()
        }
    }
    public func removeTrackFromPlaylist(track: AudioTrack, playlist: PlaylistItem, completion: @escaping (Bool) -> Void)
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/playlists/\(playlist.id)/tracks"),
                           type: .DELETE) { baseRequest in
            var request = baseRequest
            let json = [
                "tracks": [
                    ["uri": "spotify:track:\(track.id)"]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _ , error in
                guard let data = data, error == nil else
                {
                    completion(false)
                    return
                }
                do
                {
                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    if let repsonse = result as? [String: Any],
                       repsonse["snapshot_id"] as? String != nil
                    {
                        completion(true)
                    }
                }
                catch
                {
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists( completion: @escaping ((Result<FeaturedPlaylistResponse, Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/browse/featured-playlists?limit=20"), type: .GET) { baseRequest in
            // task is usually a data request that is sent to the server
            let task = URLSession.shared.dataTask(with: baseRequest) { (data,_,error) in
                guard let data = data, error == nil else
                {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Categories
    public func getBrowseCategories( completion: @escaping ((Result<AllCategoriesReponse, Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/browse/categories" ), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(AllCategoriesReponse.self, from: data)
                    completion(.success(result))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func getCategoryPlaylist(with category:CategoryReponseItem, completion: @escaping((Result<[PlaylistItem], Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/browse/categories/\(category.id)/playlists?limit=50"), type: .GET){ baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest)
            { (data,_,error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(CategoryPlaylistResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
    // MARK: - Search
    public func getSearchQuery(with searchQuery: String, completion: @escaping ((Result<[SearchResult], Error>) -> Void))
    {
        self.createRequest(with: URL(string: Constants.baseAPIUrl + "/search?limit=10&type=album,artist,playlist,track&q=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest){ (data, _, error) in
                print(baseRequest.url?.absoluteString ?? "none")
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do
                {
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    
                    var searchResult: [SearchResult] = []
                    
                    searchResult.append(contentsOf: result.artists.items.compactMap({
                        SearchResult.artist(model: $0)
                    }))
                    searchResult.append(contentsOf: result.albums.items.compactMap({
                        SearchResult.album(model: $0)
                    }))
                    searchResult.append(contentsOf: result.tracks.items.compactMap({
                        SearchResult.track(model: $0)
                    }))
                    searchResult.append(contentsOf: result.playlists.items.compactMap({
                        SearchResult.playlist(model: $0)
                    }))
                    
                    completion(.success(searchResult))
                }
                catch
                {
                    completion(.failure(APIError.failedToGetData))
                }
            }
            task.resume()
        }
    }
    
}
