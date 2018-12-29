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
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var celeView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBAction func nestahovatBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        existujeNovaVerzeDTBZ = false
    }
    
    @IBAction func stahnoutBtn(_ sender: Any) {
        /*
        let url = URL(string: "http://socka.funsite.cz/databaze")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
        */
        stahniNovouDtbz()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    */
    
    override func viewDidLoad() {
        
        textView.layer.cornerRadius = 15.0
        celeView.layer.cornerRadius = 15.0
        
        super.viewDidLoad()
        /*
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        
        */
        progressView.setProgress(0.0, animated: false)
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
                self.progressView.setProgress((Float(progress.fractionCompleted)), animated: true)
                self.progressLabel.text = "\(Int(progress.fractionCompleted * 100)) %"
                self.textView.text = "Probíhá stahování."
            }
            
            .response{response in
                
                if response.error == nil{
                    
                    self.celeView.isHidden = true
                    
                    let alert = UIAlertController(title: "Jízdní řády byly aktualizovány.", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.dismiss(animated: true, completion: nil)}
                    ))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    let downloader = Downloader()
                    downloader.zapisVerziDtbzDoUserDefaults(novaVerze: downloader.zjistiVerziDtbzNaWebu())

                }else{
                    
                    self.celeView.isHidden = true
                    
                    let alert = UIAlertController(title: "Chyba.", message: "Chyba při ukládání nové databáze. Zkuste Socku restartovat.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                        self.dismiss(animated: true, completion: nil)}))
                    self.present(alert, animated: true, completion: nil)
                    
                    print(response.error)
                }
        }
    }
    
    
/*
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataBaze")

        do{
            try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
            try FileManager.default.copyItem(at: location, to: destinationFileUrlbezPripony)
            textView.text = "Jízdní řády jsou aktuální."
            
            self.celeView.isHidden = true
            
            let alert = UIAlertController(title: "Jízdní řády byly aktualizovány.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
            self.dismiss(animated: true, completion: nil)}
            ))
            
            
            self.present(alert, animated: true, completion: nil)

            
            let downloader = Downloader()
            downloader.zapisVerziDtbzDoUserDefaults(novaVerze: downloader.zjistiVerziDtbzNaWebu())
            
        }catch{
            print("Error pri mazani a kopirování nové DTBZ")
            
            self.celeView.isHidden = true
            
            let alert = UIAlertController(title: "Chyba.", message: "Chyba při ukládání nové databáze. Zkuste Socku restartovat.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)

        }

    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
        progressLabel.text = "\(Int(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite) * 100)) %"
        textView.text = "Probíhá stahování."
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
            
        }
    }

*/
}
