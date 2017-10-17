//
//  InfoViewController.swift
//  myLocation
//
//  Created by Boocha on 05.10.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var zavritBTN: UIButton!
    @IBOutlet weak var hlavniLabel: UILabel!
    
    @IBAction func zavritBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        
        hlavniLabel.adjustsFontSizeToFitWidth = true
        super.viewDidLoad()
        hlavniLabel.allowsDefaultTighteningForTruncation = true
        hlavniLabel.minimumScaleFactor = 0.1
        
        scrollView.bottomAnchor.constraint(equalTo: zavritBTN.bottomAnchor).isActive = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMailApp() {
        
        let toEmail = "stavik@outlook.com"
        let subject = "Test email".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let body = "Just testing ...".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        let urlString = "mailto:\(toEmail)?subject=\(subject)&body=\(body)"
        let url = URL(string:urlString)
        UIApplication.shared.openURL(url!)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
