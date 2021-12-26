//
//  ExploreController.swift
//  TwitterTutorial
//
//  Created by doyun on 2021/12/21.
//

import UIKit

class ExploreController: UIViewController {
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
    //MARK: - helper
    func configureUI(){
        self.view.backgroundColor = .white
        
        navigationItem.title = "Explore"
    }
}
