//
//  SearchViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController
{
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController:  SearchResultsViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private var browseCategories = [CategoryReponseItem]()
    
    
    private let collectionView: UICollectionView = UICollectionView(frame: .zero,
                                                                    collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { ( _, _ ) -> NSCollectionLayoutSection? in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2,
                                                     leading: 7,
                                                     bottom: 2,
                                                     trailing: 7)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .absolute(150)),
                                                       subitem: item,
                                                       count: 2)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                     leading: 0,
                                                     bottom: 10,
                                                     trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        return section
    }))
    
    /// Mark: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.getBrowseCategories()
        navigationItem.searchController = self.searchController
        view.addSubview(self.collectionView)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(CategoryCollectionViewCell.self,  forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = view.bounds
    }
    
    private func getBrowseCategories()
    {
        APICaller.shared.getBrowseCategories() { [weak self] result in
            DispatchQueue.main.async {
                switch result
                {
                case .success(let categories ):
                    self?.browseCategories.append(contentsOf: categories.categories.items)
                    self?.collectionView.reloadData()
                case .failure(let model):
                    break
                }
            }
        }
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.browseCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else { return UICollectionViewCell()}
        let category = self.browseCategories[indexPath.row]
        let viewModel = CategoryCollectionViewCellViewModel(title: category.name,
                                                            artworkURL: URL(string: category.icons.first?.url ?? ""))
        cell.configure(with: viewModel)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticsManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let categoryPlaylistItem = self.browseCategories[indexPath.row]
        let vc = CategoryViewController(category: categoryPlaylistItem)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchResultsUpdating, UISearchBarDelegate

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate
{
    func updateSearchResults(for searchController: UISearchController)
    {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController, let query = searchController.searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty
        else
        {
            return
        }
        
        resultsController.delegate = self
        
        APICaller.shared.getSearchQuery(with: query) {result in
            DispatchQueue.main.async {
                switch result
                {
                case .success(let results):
                    resultsController.update(with: results)
                case .failure(let error):
                    break
                }
            }
        }
    }
}
// MARK: - SearchResultsViewControllerDelegate
extension SearchViewController: SearchResultsViewControllerDelegate
{
    func didTapResult(_ result: SearchResult) {
        switch result{
        case .artist(let artist):
            guard let urlString = artist.external_urls["spotify"], let urlString = URL(string: urlString)  else{return}
            let vc = SFSafariViewController(url: urlString)
            present(vc, animated: true)
        case .album(let album):
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .track(let track):
            PlaybackPresenter.shared.startPlayback(from: self, track: track)
        case .playlist(let playlist):
            let vc = PlaylistViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
