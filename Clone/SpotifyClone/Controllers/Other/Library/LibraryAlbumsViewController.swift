//
//  LibraryAlbumsViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/1/23.
//

import UIKit

class LibraryAlbumsViewController: UIViewController
{
    private var albums:[Album] = [Album]()
    
    private let noAlbumsView = ActionLabelView()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
        
    }()
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNoAlbumsView()
        self.fetchAlbums()
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        observer = NotificationCenter.default.addObserver(forName: .albumSavedNotification,
                                                          object: nil, queue: .main, using: { [weak self] _ in
            DispatchQueue.main.async {
                self?.fetchAlbums()
                self?.tableView.reloadData()
            }
        })
    }
    
    @objc private func didTapClose()
    {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchAlbums()
    {
        self.albums.removeAll()
        APICaller.shared.getCurrentUserAlbums{ [weak self] result in
            DispatchQueue.main.async
            {
                switch result
                {
                case .success(let userAlbums):
                    self?.albums = userAlbums
                    self?.updateUI()
                case .failure(let error):
                    break
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        noAlbumsView.frame = CGRect(x: (view.width - 150) / 2,
                                       y: (view.height - 150) / 2,
                                       width: 150,
                                       height: 150)
        tableView.frame = view.bounds
    }
    
    private func setUpNoAlbumsView()
    {
        view.addSubview(self.noAlbumsView)
        self.noAlbumsView.delegate = self
        let viewModel = ActionLabelViewViewModel(text: "You do not have any saved albums yet",
                                                 actionTitle: "Browse")
        noAlbumsView.configure(with: viewModel)
    }
    
    private func updateUI()
    {
        if ((self.albums.isEmpty)){
            // show label
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        }
        else
        {
            // Show Table
            self.tableView.reloadData()
            noAlbumsView.isHidden = true
            tableView.isHidden = false
        }
    }
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate
{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
    {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {return UITableViewCell()}
        let album = self.albums[indexPath.row]
        let viewModel = SearchResultsSubtitleTableViewCellViewModel(title: album.name,
                                                                    subtitle: album.artists.first?.name ?? "-",
                                                                    imageURL: URL(string: album.images.first?.url ?? "" ))
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let album = self.albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
