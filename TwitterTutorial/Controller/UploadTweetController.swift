//
//  UploadTweetController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/28.
//

import UIKit

class UploadTweetController: UIViewController {

    //MARK: - Property
    
    private let user:User
    private let config:UploadTweetConfiguration
    private lazy var viewModel = UploadTweetViewModel(config: config)
    
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32/2
        
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    
    private let profileImageView : UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.setDimensions(width: 48, height: 48)
        iv.layer.cornerRadius = 48/2
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private let captionTextview = CaptionTextView()
    private lazy var replyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "Reply"
        label.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        return label
    }()
    
    //MARK: - Likecycle
    init(user: User,config: UploadTweetConfiguration) {
        self.user = user
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        switch config {
        case .tweet :
            print("configuration: tweet")
        case .reply(let tweet) :
            print("replying to \(tweet.caption)")
        }
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Selectors
    @objc func handleUploadTweet(){
        guard let caption = captionTextview.text else { return }
        TweetService.shared.updateTweet(caption: caption,type:config) { (error, ref) in
            if let error = error {
                print("DEBUG: faild to upload tweet with error \(error.localizedDescription)")
                return
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - API
    
    //MARK: - helpers
    func configureUI() {
        view.backgroundColor = .white
        configureNavigationBar()
        
        let imageStack = UIStackView(arrangedSubviews: [profileImageView,captionTextview])
        imageStack.axis = .horizontal
        imageStack.spacing = 12
        imageStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel,imageStack])
        stack.axis = .vertical
        stack.spacing = 12

        view.addSubview(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16,paddingRight: 16)
        
        profileImageView.sd_setImage(with: user.profileimageURL, completed: nil)
        
        actionButton.setTitle(viewModel.actionButtonTitle,for:.normal)
        captionTextview.placeholder.text = viewModel.placeholderText
        
        replyLabel.isHidden = !viewModel.shoulShowReplyLabel
        guard let replyText = viewModel.replyText else { return }
        replyLabel.text = replyText
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: actionButton)
        
    }
}
