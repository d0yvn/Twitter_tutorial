//
//  EditProfileController.swift
//  TwitterTutorial
//
//  Created by doyun on 2022/01/08.
//

import Foundation
import UIKit

private let reuseIdentifier = "EditProfileCell"

protocol EditProfileControllerDelegate:class {
    func controller(_ controller: EditProfileController,wantToUpdate user: User)
    func handleLogout()
}

class EditProfileController: UITableViewController{
    //MARK: - Properties
    
    private var user:User
    private lazy var headerView = EditProfileHeader(user:user)
    private let imagePicker = UIImagePickerController()
    
    private var userInfoChanged = false
    weak var delegate:EditProfileControllerDelegate?
    
    private var selectedImage:UIImage? {
        didSet{ headerView.profileImageView.image = selectedImage }
    }
    
    private let footerView = EditProfileFooter()
    
    //MARK: - Lifecycle
    init(user:User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureTableView()
        configureImagePicker()
    }
    
    //MARK: - Selectors
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone(){
        updateUserData()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - API
    
    func updateUserData() {
        UserService.shared.saveUserData(user: user) { (err,ref) in
            self.delegate?.controller(self, wantToUpdate: self.user)
        }
    }
    
    //MARK: - Helper
    func configureNavigationBar(){
        navigationController?.navigationBar.backgroundColor = .twitterBlue
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.tintColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 180)
        
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        footerView.backgroundColor = .red
        tableView.tableFooterView = footerView
        footerView.delegate = self
        
        headerView.delegate = self
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    func configureImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}

//MARK: - UITableVIewDelegate

extension EditProfileController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! EditProfileCell
        cell.delegate = self
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return cell }
        cell.viewModel = EditProfileViewModel(user:user,option: option)
        
        return cell
    }
}

extension EditProfileController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else { return 0}
        
        return option == .bio ? 100 : 48
    }
}

//MARK: - EditProfileHeaderDelegate
extension EditProfileController: EditProfileHeaderDelegate {
    func didTapChangeProfilePhoto() {
        present(imagePicker,animated: true,completion: nil)
        print("DEBUG: Handle Change Photo")
    }
}

//MARK: - UIImagePickerDelegate

extension EditProfileController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        self.selectedImage = image
        
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - EditProfileCellDelegate
extension EditProfileController: EditProfileCellDelagte {
    func updateUserInfo(_ cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else { return }
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname :
            guard let fullname = cell.infoTextField.text else { return }
            user.fullname = fullname
        case .username :
            guard let username = cell.infoTextField.text else { return }
            user.username = username
        case .bio:
            user.bio = cell.bioTextView.text
            
        }
    }
}

extension EditProfileController : EditProfileFooterDelegate {
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            self.dismiss(animated: true) {
                self.delegate?.handleLogout()
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
