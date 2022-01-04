
import UIKit
import Firebase

class MainTapController: UITabBarController {

    //MARK: - Properties
    var user : User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else { return }
            // viewControllers[0] => UINavtigationController
            guard let feed = nav.viewControllers.first as? FeedContoller else { return }
            // nagavtionController중 제일 처음.s
            feed.user = user
        }
    }
    
    let actionButton : UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
//        logUserOut()
        authenticateUserAndConfigureUI()
    }
    
    //MARK: - API call
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid, completion: { user in
            self.user = user
        })
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            //유저 로그인 X
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            // 유저 로그인 O
            configureViewControllers() //탭바 설정.
            configureUI()
            fetchUser()
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("failed to logout \(error.localizedDescription)")
        }
    }
    
    //MARK: - selectors
    @objc func buttonTapped(){
        guard let user = user else { return }
        let controller = UploadTweetController(user: user,config:.tweet)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - helper
    func configureUI(){
        view.backgroundColor = .white
        tabBar.isTranslucent = false
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56 )
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers(){
        let feed = FeedContoller(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = ExploreController()
        let nav2 = templateNavigationController(image: UIImage(named: "search_unselected"), rootViewController: explore)
        
        let notifications = NotificationsController()
        let nav3 = templateNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notifications)

        let conversations = ConversationsController()
        let nav4 = templateNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: conversations)
        
        setViewControllers([nav1,nav2,nav3,nav4], animated: false)
        
    }
    
    func templateNavigationController(image: UIImage?,rootViewController: UIViewController) -> UINavigationController{
        
        let navigation = UINavigationController(rootViewController: rootViewController)
        navigation.tabBarItem.image = image
        navigation.navigationBar.tintColor = .white
        return navigation
    }

}
