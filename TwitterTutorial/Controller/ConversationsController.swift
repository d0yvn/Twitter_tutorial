//
//  ConversationsController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/21.
//

import UIKit

class ConversationsController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        // Do any additional setup after loading the view.
    }
    
    func configureUI(){
        self.view.backgroundColor = .white
        
        navigationItem.title = "Messages"
    }

}
