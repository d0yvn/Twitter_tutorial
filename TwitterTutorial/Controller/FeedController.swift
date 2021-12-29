
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
        fetchTweet()
    }
    
    //MARK: - API
    func fetchTweet() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
        }
        
    }
    
    //MARK: - helper
    func configureUI(){
        self.view.backgroundColor = .white
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
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

//MARK: - UICollectionViewdDelegate/DataSource
extension FeedContoller {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TweetCell else { return UICollectionViewCell()}
        cell.tweet = tweets[indexPath.row]
        
        return cell
       
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension FeedContoller : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 120)
    }
}
