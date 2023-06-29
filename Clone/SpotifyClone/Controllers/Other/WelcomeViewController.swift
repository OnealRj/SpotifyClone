//
//  WelcomeViewController.swift
//  SpotifyClone
//
//  Created by Rj O'Neal on 5/14/23.
//

import UIKit

class WelcomeViewController: UIViewController
{
    private let signInButton: UIButton =
    {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In With Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let backgroundImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums_background")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.8
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AppIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32,
                                 weight: .semibold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Listen to Millions \nof Songs on\n the go!"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        view.backgroundColor = .black
        self.title = "Spotify"
        self.view.backgroundColor = .systemGreen
        view.addSubview(backgroundImageView)
        view.addSubview(overlayView)
        view.addSubview(logoImageView)
        view.addSubview(label)
        view.addSubview(self.signInButton)
        self.signInButton.addTarget(self, action: #selector(self.didTapSignIn), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
        overlayView.frame = view.bounds
        logoImageView.frame = CGRect(x: (view.width-120) / 2,
                                     y: (view.height-350)/2,
                                     width: 120,
                                     height: 120)
        label.frame = CGRect(x: 30,
                             y: logoImageView.bottom + 30,
                             width: view.width - 60,
                             height: 150)
        
        self.signInButton.frame = CGRect(x: 20, y: view.height - 50 - view.safeAreaInsets.bottom, width: view.width - 40, height: 50)
    }
    
    @objc func didTapSignIn()
    {
        let vc = AuthViewController()
       
        vc.completionHandeler = { [weak self] (success) in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
                
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool)
    {
        guard success else
        {
            let alert = UIAlertController(title: "Ooops", message: "Something went wrong when signing in", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }

}
