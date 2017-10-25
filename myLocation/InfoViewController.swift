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
    
    @IBAction func kontaktButton(_ sender: Any) {
        let email = "bucek.jiri@email.cz"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
        
    }
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

}
