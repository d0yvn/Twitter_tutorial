//
//  NotificaationsController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/21.
//

import UIKit

class NotificationsController: UIViewController {
    
    //MARK: - Properties
    
    //MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func configureUI(){
        self.view.backgroundColor = .white
        navigationItem.title = "Notifications"
    }

}
