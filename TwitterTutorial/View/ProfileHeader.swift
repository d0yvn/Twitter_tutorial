import UIKit

protocol ProfileHeaderDelegate: class {
    func handleDismissal()
    func handleEditProfileFollow(_ header: ProfileHeader)
}

// supplementary cell 생성시 UICollectinonReuseableView 사용.
class ProfileHeader : UICollectionReusableView {
    //MARK: - Properties
    var user: User? {
        didSet{
            configure() // header 호출되면 자동으로 configure()
        }
    }
    weak var delegate: ProfileHeaderDelegate?
    
    private let filterBar = ProfileFilterView()
    
    private lazy var containerView :UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        return view
    }()
    
    private lazy var backButton :UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(backbuttonTapped), for: .touchUpInside)
        return button
    }()
    
    private let profileImageview : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderWidth = 4
        imageView.layer.borderColor = UIColor.white.cgColor
        
        return imageView
    }()
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton()
        button.setTitle("Follow", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        return button
    }()
    
    private let fullnameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
        
    }()
    private let bioLabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "This is bio label that will span more than one line test purpose"
        return label
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        
        return view
    }()
    
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Following"
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.text = "0 followers"
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(profileImageview)
        profileImageview.anchor(top: containerView.bottomAnchor,
                                left: leftAnchor, paddingTop: -24, paddingLeft: 8)
        profileImageview.setDimensions(width: 80, height: 80)
        profileImageview.layer.cornerRadius = 80 / 2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: containerView.bottomAnchor, right: rightAnchor,
                                       paddingTop: 12, paddingRight: 12)
        
        editProfileFollowButton.setDimensions(width: 100, height:44)
        editProfileFollowButton.layer.cornerRadius = 44 / 2
        
        let userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel,usernameLabel,bioLabel])
        userDetailStack.axis = .vertical
        userDetailStack.distribution = .fillProportionally
        userDetailStack.spacing = 4
        
        addSubview(userDetailStack)
        userDetailStack.anchor(top: profileImageview.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel,followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        
        addSubview(followStack)
        followStack.anchor(top: userDetailStack.bottomAnchor, left: leftAnchor,
                           paddingTop: 8, paddingLeft: 12)
        
        addSubview(filterBar)
        filterBar.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,height: 50)
        filterBar.delegate = self
        
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor,width:frame.width/3, height: 2)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - selectors
    
    @objc func backbuttonTapped() {
        delegate?.handleDismissal()
    }
    
    @objc func handleEditProfileFollow() {
        delegate?.handleEditProfileFollow(self)
    }
    
    @objc func handleFollowersTapped() {
        
    }
    @objc func handleFollowingTapped() {
        
    }
    
    //MARK: - helpers
    
    func configure() {
        guard let user = user else { return }
        let viewModel = ProfileHeaderViewModel(user: user)
        
        profileImageview.sd_setImage(with: user.profileimageURL)
        
        followingLabel.attributedText = viewModel.followingText
        followersLabel.attributedText = viewModel.followerText
        editProfileFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
    }
}

//MARK: - ProfileFilterViewDelegate
extension ProfileHeader: ProfileFilterViewDelegate {
    
    //tweet,tweet&replies,likes 상태바 터치 상태 변화.
    func filterView(_ view: ProfileFilterView, didSeletect indexPath: IndexPath) {
        guard let cell = view.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else { return }
        
        let xPosition = cell.frame.origin.x
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
    }
}
