//
//  UpgradeViewController.swift
//  myLocation
//
//  Created by Boocha on 31.05.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit


class UpgradeViewController: UIViewController, URLSessionDownloadDelegate{
    

    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBOutlet weak var downloadProgressLabel: UILabel!
    
    @IBAction func nestahovatBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        existujeNovaVerzeDTBZ = false
    }
    
    @IBAction func stahnoutBtn(_ sender: Any) {
        let url = URL(string: "http://socka.funsite.cz/databaze")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    
    @IBAction func startDownload(_ sender: AnyObject) {
        let url = URL(string: "http://publications.gbdirect.co.uk/c_book/thecbook.pdf")!
        downloadTask = backgroundSession.downloadTask(with: url)
        downloadTask.resume()
    }
    @IBAction func pause(_ sender: AnyObject) {
        if downloadTask != nil{
            downloadTask.suspend()
        }
    }
    @IBAction func resume(_ sender: AnyObject) {
        if downloadTask != nil{
            downloadTask.resume()
        }
    }
    @IBAction func cancel(_ sender: AnyObject) {
        if downloadTask != nil{
            downloadTask.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressView.setProgress(0.0, animated: false)

        
        //downloadAndSave(mojeSession: backgroundSession)
    }
    
    /*func downloadAndSave(mojeSession: URLSession){
        //stáhne soubor z URL a uloží ho do složky dokumenty
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataFinal280417")
        //jmeno souboru, ktery se ulozi
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "http://socka.funsite.cz/databaze")
        //URL, ze ktereho stahuji
        
        //let sessionConfig = URLSessionConfiguration.default
        let session = mojeSession
        //let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request)
        
        
        do{
            try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
            //try FileManager.default.copyItem(at: fileURL!, to: destinationFileUrlbezPripony)
        }catch{
                    print("Error pri mazani filu")
        }
        
        task.resume()
        
    }*/
    
    
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let destinationFileUrlbezPripony = documentsUrl.appendingPathComponent("DataFinal280417")

        do{
            try FileManager.default.removeItem(at: destinationFileUrlbezPripony)
            try FileManager.default.copyItem(at: location, to: destinationFileUrlbezPripony)
        }catch{
            print("Error pri mazani filu")
        }

    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        print(totalBytesWritten)
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
        //progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    
    
    

}
