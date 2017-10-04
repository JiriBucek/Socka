//
//  UpgradeViewController.swift
//  myLocation
//
//  Created by Boocha on 31.05.17.
//  Copyright © 2017 Boocha. All rights reserved.
//

import UIKit


class UpgradeViewController: UIViewController, URLSessionDownloadDelegate{
    
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    @IBOutlet weak var celeView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
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
    
    
    override func viewDidLoad() {
        
        textView.layer.cornerRadius = 15.0
        celeView.layer.cornerRadius = 15.0
        
        super.viewDidLoad()
        
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        progressView.setProgress(0.0, animated: false)

        
    }
    
    func zapisVerziDtbzDoUserDefaults(novaVerze: Int){
        print("spusteno2")
        UserDefaults.standard.set(novaVerze, forKey: "verzeDtbz")
    }
    
    

    
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
            aktualneZobrazovanaStanice = "Upgrade"
            textView.text = "Jízdní řády jsou aktuální."
            let downloader = Downloader()
            downloader.zapisVerziDtbzDoUserDefaults(novaVerze: downloader.zjistiVerziDtbzNaWebu())
            
        }catch{
            print("Error pri mazani a kopirování nové DTBZ")
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


}
