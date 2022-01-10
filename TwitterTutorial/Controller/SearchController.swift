import UIKit

private let identifier = "UserCell"

enum SearchControllerConfiguration {
    case messages
    case userSearch
}
class SearchController: UITableViewController {
    
    //MARK: - Properties
    
    private let config: SearchControllerConfiguration
    
    private var users = [User]() {
        didSet{ tableView.reloadData() }
    }
    
    private var filterdUsers = [User]() {
        didSet {tableView.reloadData()}
    }
    
    private var isSearchMode:Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - LifeCycles
    
    init(config: SearchControllerConfiguration) {
        self.config = config
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Selector
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - API
    
    func fetchUsers() {
        UserService.shared.fetchUsers { users in
            self.users = users
        }
    }
    
    //MARK: - helper
    func configureUI(){
        view.backgroundColor = .white
        navigationItem.title = "Explore"
        tableView.register(UserCell.self, forCellReuseIdentifier: identifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        if config == .messages {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleDismissal))
        }
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

extension SearchController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchMode ? filterdUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UserCell
        let user = isSearchMode ? filterdUsers[indexPath.row] : users[indexPath.row]
        cell.user = user
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let controller = ProfileController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filterdUsers = users.filter({ $0.username.contains(searchText)})
    }
}
