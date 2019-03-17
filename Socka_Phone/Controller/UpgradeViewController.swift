//
//  UpgradeViewController.swift
//  myLocation
//
//  Created by Boocha on 31.05.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit
import Alamofire


class UpgradeViewController: UIViewController{
    // VC pro aktualizaci databaze.
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var celeView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBAction func nestahovatBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        existujeNovaVerzeDTBZ = false
    }
    
    @IBAction func stahnoutBtn(_ sender: Any) {
        stahniNovouDtbz()
    }
    
    
    override func viewDidLoad() {
        textView.layer.cornerRadius = 15.0
        celeView.layer.cornerRadius = 15.0
        
        super.viewDidLoad()

        progressView.setProgress(0.0, animated: false)
    }
    
    func stahniNovouDtbz(){
        // Stáhne přes Alamofire soubor databáze z webu a zkopíruje jej do složky dokumentů. Pokud už tam něco je, tak ten soubor přemaže.
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("DataBaze")
            
            return (fileURL, [.removePreviousFile])
        }
        
        Alamofire.download("http://socka.funsite.cz/databaze", to: destination)
            .downloadProgress { progress in
                print("Download Progress: \(progress.fractionCompleted)")
                self.progressView.setProgress((Float(progress.fractionCompleted)), animated: true)
                self.progressLabel.text = "\(Int(progress.fractionCompleted * 100)) %"
                self.textView.text = "Probíhá stahování."
            }
            
            .response{response in
                
                if response.error == nil{
                    // Uspech.
                    self.celeView.isHidden = true
                    
                    let alert = UIAlertController(title: "Jízdní řády byly aktualizovány.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.dismiss(animated: true, completion: nil)}
                    ))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    let databaze = Databaze.sharedPhone
                    databaze.zapisVerziDtbzDoUserDefaults(novaVerze: databaze.zjistiVerziDtbzNaWebu())

                }else{
                    // Neuspech.
                    self.celeView.isHidden = true
                    
                    let alert = UIAlertController(title: "Chyba.", message: "Chyba při ukládání nové databáze. Zkuste Socku restartovat.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.dismiss(animated: true, completion: nil)}))
                    self.present(alert, animated: true, completion: nil)
                    
                    print(response.error!)
                }
        }
    }
}
