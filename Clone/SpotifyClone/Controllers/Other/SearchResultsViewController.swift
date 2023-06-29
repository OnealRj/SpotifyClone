//
//  SearchResultsViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/28/23.
//

import UIKit

struct SearchSection
{
    let title: String
    let results: [SearchResult]
}

protocol SearchResultsViewControllerDelegate: AnyObject
{
    func didTapResult( _ result: SearchResult)
}

class SearchResultsViewController: UIViewController
{
    private var sections: [SearchSection] = []
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        tableView.register(SearchResultsSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func update(with results:[SearchResult])
    {
        let artists = results.filter({
            switch $0
            {
                case .artist: return true
                default: return false
            }
        })
        
        let albums = results.filter({
            switch $0
            {
            case .album: return true
                default: return false
            }
        })
        
        let playlists = results.filter({
            switch $0
            {
            case .playlist: return true
                default: return false
            }
        })
        
        let tracks = results.filter({
            switch $0
            {
            case .track: return true
                default: return false
            }
        })
        
        self.sections = [SearchSection(title: "Artists", results: artists),
                         SearchSection(title: "Albums", results: albums),
                         SearchSection(title: "Playlists", results: playlists),
                         SearchSection(title: "Tracks", results: tracks)]
        self.tableView.reloadData()
        tableView.isHidden = self.sections.isEmpty
    }
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].results.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = self.sections[indexPath.section].results[indexPath.row]
        switch result
        {
        case .artist(let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultDefaultTableViewCell
            else { return UITableViewCell()}
            let viewModel = SearchResultDefaultTableViewCellViewModel(title: artist.name,
                                                                      imageURL: URL(string: artist.images?.first?.url ?? "https://preview.redd.it/t20txl4c9sy41.png?width=750&format=png&auto=webp&s=e4c7535f4eb0ec05d4a7a0690a6317852a19c84c"))
            cell.configure(with: viewModel)
            return cell
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultsSubtitleTableViewCell
            else { return UITableViewCell()}
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(title: album.name,
                                                                        subtitle: album.artists.first?.name ?? "",
                                                                        imageURL: URL(string: album.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .track(let track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultsSubtitleTableViewCell
            else { return UITableViewCell()}
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(title: track.name,
                                                                        subtitle: track.artists.first?.name ?? "",
                                                                        imageURL: URL(string: track.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .playlist(let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier,
                                                           for: indexPath) as? SearchResultsSubtitleTableViewCell
            else { return UITableViewCell()}
            let viewModel = SearchResultsSubtitleTableViewCellViewModel(title: playlist.name,
                                                                        subtitle: playlist.owner.display_name ?? "",
                                                                        imageURL: URL(string: playlist.images?.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let result = self.sections[indexPath.section].results[indexPath.row]
        delegate?.didTapResult(result)
    }
    
}
