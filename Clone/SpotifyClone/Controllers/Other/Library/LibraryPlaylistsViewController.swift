//
//  LibraryPlaylistsViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 6/1/23.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController
{
    private var playlists:[PlaylistItem] = [PlaylistItem]()
    
    private let noPlaylistsView = ActionLabelView()
    
    public var selectionHandler: ((PlaylistItem) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsSubtitleTableViewCell.self,
                           forCellReuseIdentifier: SearchResultsSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
        
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpNoPlaylistsView()
        self.fetchPlaylists()
        self.view.addSubview(tableView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        if selectionHandler != nil
        {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    @objc private func didTapClose()
    {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchPlaylists()
    {
        APICaller.shared.getCurrentUserPlaylists{ [weak self] result in
            DispatchQueue.main.async
            {
                switch result
                {
                case .success(let userPlaylists):
                    self?.playlists = userPlaylists
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
        
        noPlaylistsView.frame = CGRect(x: 0,
                                       y: 0,
                                       width: 150,
                                       height: 150)
        noPlaylistsView.center = view.center
        
        tableView.frame = view.bounds
    }
    
    private func setUpNoPlaylistsView()
    {
        view.addSubview(self.noPlaylistsView)
        self.noPlaylistsView.delegate = self
        let viewModel = ActionLabelViewViewModel(text: "You do not have any playlists yet",
                                                 actionTitle: "Create")
        noPlaylistsView.configure(with: viewModel)
    }
    
    private func updateUI()
    {
        if ((self.playlists.isEmpty)){
            // show label
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        }
        else
        {
            // Show Table
            self.tableView.reloadData()
            noPlaylistsView.isHidden = true
            tableView.isHidden = false
        }
    }
    public func showCreatePlaylistAlert()
    {
        // Show Creation UI
        let alert = UIAlertController(title: "New Playlist",
                                      message: "Enter playlist name",
                                      preferredStyle: .alert)
        
        alert.addTextField{ textField in
            textField.placeholder = "Playlist..."
        }
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel, handler: nil))
        
        
        alert.addAction(UIAlertAction(title: "create",
                                      style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else
            {
                return
            }
            
            APICaller.shared.createPlaylists(with: text) { [weak self] success in
                if success {
                    // refresh list of Playlist
                    HapticsManager.shared.vibrate(for: .success)
                    DispatchQueue.main.async {
                        self?.fetchPlaylists()
                        self?.tableView.reloadData()
                    }
                }
                else
                {
                    HapticsManager.shared.vibrate(for: .error)
                    print("Failed to create playlist")
                }
            }
            
        }))
        present(alert, animated: true)
    }
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate
{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView)
    {
        self.showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultsSubtitleTableViewCell else {return UITableViewCell()}
        let playlist = self.playlists[indexPath.row]
        let viewModel = SearchResultsSubtitleTableViewCellViewModel(title: playlist.name,
                                                                    subtitle: playlist.owner.display_name,
                                                                    imageURL: URL(string: playlist.images?.first?.url ?? "" ))
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let playlist = self.playlists[indexPath.row]
        if selectionHandler == nil
        {
            let vc = PlaylistViewController(playlist: playlist)
            if playlist.owner.display_name == "Rj Oneal"
            {
                vc.isOwner = true
            }
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.present(vc, animated: true)
        }
        else
        {
            selectionHandler?(playlist)
            dismiss(animated: true)
        }
        
    }
    
}
