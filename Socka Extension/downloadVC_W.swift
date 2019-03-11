//
//  downloadVC_W.swift
//  Socka Extension
//
//  Created by Boocha on 26.12.18.
//  Copyright © 2018 Boocha. All rights reserved.
//
import WatchKit
import UIKit
import Foundation
import Alamofire


class downloadVC_W: WKInterfaceController {
    
    @IBOutlet var percentOutlet: WKInterfaceLabel!
    
    override func willActivate() {
        stahniNovouDtbz()
    }
    
    func stahniNovouDtbz(){
    //Stáhne přes Alamofire soubor databáze z webu a zkopíruje jej do služky dokumentů. Pokud už tam něco je, tak ten soubor přemaže.
    
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("DataBaze")
            
            return (fileURL, [.removePreviousFile])
        }
        
        Alamofire.download("http://socka.funsite.cz/databaze", to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
                self.percentOutlet.setText("\(Int(progress.fractionCompleted * 100)) %")
        }
        
            .response{response in
                
                if response.error == nil{
                    
                    let presentMainVC = {
                        self.popToRootController()
                    }
                    
                    let action1 = WKAlertAction(title: "Ok", style: .default, handler: presentMainVC)
                    self.presentAlert(withTitle: "Jízdní řády jsou aktuální.", message: nil, preferredStyle: .alert, actions: [action1])
                    
                    let dl = Downloader_W()
                    dl.zapisVerziDtbzDoUserDefaultsHodinek(novaVerze: dl.zjistiVerziDtbzNaWebu())
                    
                }else{
                    print(response.error as Any)
                }
            }
        }
}
