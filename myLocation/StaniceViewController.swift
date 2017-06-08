//
//  StaniceViewController.swift
//  myLocation
//
//  Created by Boocha on 31.05.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit

class StaniceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        getPrujezdniZastavky()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPrujezdniZastavky(){
        //dostanu seznam zastavek, kteryma budu projizdet
        
        var indexSoucasneZastavky = Int(seznamStanic.index(of: hlavniStanice)!)
        let indexKonecneStanice = Int(seznamStanic.index(of: konecnaStanice)!)
        var seznamPrujezdnichStanic = [String]()
        
        if indexKonecneStanice > indexSoucasneZastavky{
            
            while indexSoucasneZastavky <= indexKonecneStanice{
                seznamPrujezdnichStanic.append(seznamStanic[indexSoucasneZastavky])
                indexSoucasneZastavky += 1
            }
        }else{
            while indexSoucasneZastavky >= indexKonecneStanice{
                seznamPrujezdnichStanic.append(seznamStanic[indexSoucasneZastavky])
                indexSoucasneZastavky -= 1
            }
        }
    print(seznamPrujezdnichStanic)
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
