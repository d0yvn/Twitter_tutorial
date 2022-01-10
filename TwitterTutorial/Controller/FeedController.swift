
import UIKit
import SDWebImage

private let reuseIdentifier = "TweetCell"

class FeedContoller: UICollectionViewController {
    //MARK: - Properties
    var user: User? {
        didSet{ configureLeftBarButton() }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    //MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchTweets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - API
    func fetchTweets() {
        collectionView.refreshControl?.beginRefreshing()
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp})
            self.checkIfUserLikeTweets(self.tweets)
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikeTweets(_ tweets: [Tweet]) {
        
        
        self.tweets.forEach { tweet in
            TweetService.shared.checkIfUserLikedTweet(tweet) { didLike in
                guard didLike == true else { return }
                
                if let index = self.tweets.firstIndex(where: {$0.tweetID == tweet.tweetID}) {
                    self.tweets[index].didLike = true
                }
            }
        }
    }
    //MARK: - Selector
    
    @objc func handleRefresh() {
        fetchTweets()
    }
    @objc func handleLeftBarTapped() {
        print("DEBUG: show user profile")
        guard let user = user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    //MARK: - helper
    func configureUI(){
        self.view.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    func configureLeftBarButton() {
        guard let user = user else { return }
        let profileimageView = UIImageView()
        profileimageView.backgroundColor = .twitterBlue
        profileimageView.setDimensions(width: 32, height: 32)
        profileimageView.layer.cornerRadius = 32 / 2
        profileimageView.layer.masksToBounds = true
        profileimageView.sd_setImage(with: user.profileimageURL!, completed: nil)
        profileimageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleLeftBarTapped))
        profileimageView.addGestureRecognizer(tap)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileimageView)
    }
}

//MARK: - UICollectionViewdDelegate/DataSource
extension FeedContoller {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TweetCell else { return UICollectionViewCell()}

        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetController(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension FeedContoller : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height
        
        return CGSize(width: view.frame.width, height: height + 100)
    }
}

//MARK: - TweetCell Delegate
extension FeedContoller: TweetCellDelegate {
    
    func handleProfileImageTapped(_ cell:TweetCell) {
        guard let user = cell.tweet?.user else { return }
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleReplyTapped(_ cell: TweetCell) {
        guard let tweet = cell.tweet else { return }
        let controller = UploadTweetController(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav,animated: true,completion: nil)
    }
    func handleLikeTapped(_ cell: TweetCell){
        guard let tweet = cell.tweet else { return }
        
        TweetService.shared.likeTweet(tweet: tweet) { err,ref in
            cell.tweet?.didLike.toggle()
            cell.tweet?.likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
            
            // only upload notificaiton if tweet is being liked
            guard cell.tweet?.didLike ?? false else { return }
            NotificationServices.shared.uploadNotification(toUser:tweet.user,type: .like,tweetID: tweet.tweetID)
            
        }
    }
    
    func handleFetchUser(withUsername username: String) {
        UserService.shared.fetchUser(withUsername: username) { user in
            let vc = ProfileController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
