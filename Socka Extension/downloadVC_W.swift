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
                    
                    let presentMainVC = { self.presentController(withName: "mainVC", context: nil) }
                    let action1 = WKAlertAction(title: "Ok", style: .default, handler: presentMainVC)
                    self.presentAlert(withTitle: "Jízdní řády jsou aktuální.", message: nil, preferredStyle: .alert, actions: [action1])
                }else{
                    print(response.error)
                }
            }
        }
    
    
    
    
    
    
    
    /*
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    
    func stahniNovouDtbz(){
        print("Začínám stahovat.")
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: "http://socka.funsite.cz/databaze")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as! URL
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataBaze")
        
        do{
            try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
            try FileManager.default.copyItem(at: location, to: destinationFileUrlbezPripony)
            
            let downloader = Downloader_W()
            downloader.zapisVerziDtbzDoUserDefaultsHodinek(novaVerze: downloader.zjistiVerziDtbzNaWebu())
            
            percentOutlet.setText("Stahování ukončeno")
           
            let presentMainVC = {
                self.presentController(withName: "mainVC", context: nil)
            }
            
            let action1 = WKAlertAction(title: "Ok", style: .default, handler: presentMainVC)
            presentAlert(withTitle: "Jízdní řády jsou aktuální.", message: nil, preferredStyle: .alert, actions: [action1])
        
        }catch{
            print("Error pri mazani a kopirování nové DTBZ", error)
        }
        
    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        
        print(totalBytesWritten)
        
         //progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
         percentOutlet.setText("\(Int(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite) * 100)) %")
        
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("Stahování v hodinkách dokončeno.")
            
            
        }
    }
    
    */
    
    
}
