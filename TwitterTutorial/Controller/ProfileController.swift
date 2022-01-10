import UIKit
import Firebase

private let identifier = "TweetCell"
private let headerIdentifier = "ProfileHeader"

class ProfileController: UICollectionViewController{
    //MARK: - Propertis
    private var user: User
    
    private var selectedFilter: ProfileFilterOptions = .tweets {
        didSet { collectionView.reloadData()}
    }
    
    private var tweets = [Tweet]()
    private var likedTweet = [Tweet]()
    private var replies = [Tweet]()
    
    private var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets: return tweets
        case .replies: return replies
        case .likes: return likedTweet
        }
    }
    
    //MARK: - Lifecycle
    init(user:User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchTweets()
        fetchLikedTweet()
        fetchReplies()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    //navigiationbar hidden
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - API
    func fetchTweets() {
        TweetService.shared.fetchTweets(forUser: user) { tweets in
            self.tweets = tweets
            self.collectionView.reloadData()
        }
    }
    
    func checkIfUserIsFollowed() {
        UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.shared.fetchUserStats(uid: user.uid) { states in
            self.user.stats = states
            self.collectionView.reloadData()
        }
    }
    
    func fetchLikedTweet() {
        TweetService.shared.fetchLikes(forUser: user) { tweets in
            self.likedTweet = tweets
        }
    }
    
    func fetchReplies() {
        TweetService.shared.fetchReplies(forUser: user) { tweets in
            self.replies = tweets
        }
    }
    //MARK: - Helper
    
    func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never //safearea까지 포함되면 사이즈가 autosizing을 막는다.
        
        //collectionView -> header,tweetcell register
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
    
}

//MARK: - UICollectionViewDateSource
extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentDataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? TweetCell else { return TweetCell() }
        cell.tweet = currentDataSource[indexPath.row]
        return cell
    }
}

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: currentDataSource[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let height:CGFloat = 340
        
        
        return CGSize(width: view.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: currentDataSource[indexPath.row])
        var height = viewModel.size(forWidth: view.frame.width).height + 72
        if currentDataSource[indexPath.row].isReply {
            height += 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
}

//MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    
    func didSelect(filter: ProfileFilterOptions) {
        print("DEBUG : Did select filter \(filter.description)")
        self.selectedFilter = filter
    }
    
    
    func handleDismissal() {
        navigationController?.popViewController(animated: true)
        
    }
    func handleEditProfileFollow(_ header: ProfileHeader) {
        if user.isCurrentUser {
            let controller = EditProfileController(user: user)
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        if user.isFollowed {
            UserService.shared.unfollowUser(uid: user.uid) { (ref,error) in
                self.user.isFollowed = false
                self.collectionView.reloadData()
            }
        }else {
            UserService.shared.followUser(uid: user.uid) { (ref,error) in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                NotificationServices.shared.uploadNotification(toUser: self.user,type: .follow)
            }
        }
    }
}

//MARK: - EditProfileControllerDelegate
extension ProfileController: EditProfileControllerDelegate {
    func handleLogout() {

        do {
            try Auth.auth().signOut()
            let vc = LoginController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true, completion: nil)
        } catch let error {
            print("failed to logout \(error.localizedDescription)")
        }
        
    }
    
    func controller(_ controller: EditProfileController, wantToUpdate user: User) {
        controller.dismiss(animated: true, completion: nil)
        self.user = user
        self.collectionView.reloadData()
    }
    
    
    
}
