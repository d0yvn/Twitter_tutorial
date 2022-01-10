
import UIKit
import Firebase

enum ActionButtonConfiguration {
    case tweet
    case message
}

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
    
    private var buttonConfig: ActionButtonConfiguration = .tweet
    
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
    
    //MARK: - selectors
    @objc func buttonTapped(){
        
        let controller:UIViewController
        
        switch buttonConfig {
        case .tweet:
            guard let user = user else { return }
            controller = UploadTweetController(user: user,config:.tweet)
            print("DEBUG: Show message stuff")
        case .message:
            controller = SearchController(config: .messages)
            print("DEBUG: Show ")
        }
        
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    //MARK: - helper
    func configureUI(){
        self.delegate = self
        view.addSubview(actionButton)
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 64, paddingRight: 16, width: 56, height: 56 )
        actionButton.layer.cornerRadius = 56 / 2
    }
    
    func configureViewControllers(){
        let feed = FeedContoller(collectionViewLayout: UICollectionViewFlowLayout())
        let nav1 = templateNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feed)
        
        let explore = SearchController(config: .userSearch)
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

extension MainTapController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let index = viewControllers?.firstIndex(of: viewController)
        let imageName = index == 3 ? "mail" : "new_tweet"
        self.actionButton.setImage(UIImage(named: imageName), for: .normal)
        buttonConfig = index == 3 ? .message : .tweet
        
        if index == 3 {
            
        } else {
            
        }
    }
}
