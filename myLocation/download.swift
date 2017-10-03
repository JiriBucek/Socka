//
//  download.swift
//  myLocation
//
//  Created by Boocha on 30.09.17.
//  Copyright © 2017 Boocha. All rights reserved.
//
/*
import Foundation
import UIKit

protocol DownloadDelegate: class {
    func downloadProgressUpdate(for progress: Float)
}

final class Download {
    
    weak var delegate: DownloadDelegate?
    var url: String?
    var downloadTask: URLSessionDownloadTask?
    
    var progress: Float = 0.0 {
        didSet {
            updateProgress()
            if progress == 1 {
                downloadTask = nil
                print("File is done")
            }
        }
    }
    
    // Gives float for download progress - for delegate
    
    private func updateProgress() {
        if let task = downloadTask,
            let url = url {
            delegate?.downloadProgressUpdated(for: progress, for: url, task: task)
        }
    }
    
    init(url: String) {
        self.url = url
    }
}
 */
