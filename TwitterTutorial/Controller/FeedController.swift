//
//  FeedViewController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/21.
//

import UIKit
import SDWebImage

class FeedContoller: UIViewController {
    
    //MARK: - Properties
    
    var user: User? {
        didSet{ configureLeftBarButton() }
    }
    //MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - helper
    func configureUI(){
        self.view.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
    }
    
    func configureLeftBarButton() {

        guard let user = user else { return }
        
        let profileimageView = UIImageView()
        profileimageView.backgroundColor = .twitterBlue
        profileimageView.setDimensions(width: 32, height: 32)
        profileimageView.layer.cornerRadius = 32 / 2
        profileimageView.layer.masksToBounds = true
        profileimageView.sd_setImage(with: user.profileimageURL!, completed: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileimageView)
    }

}
