//
//  MFFBinaryDelegate.swift
//  MFFStarterIOSSwift
//
//  Created by Ignacio on 2018/05/17.
//  Copyright © 2018 Ignacio. All rights reserved.
//

import Foundation

class MFFBinaryDelegate: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {

    var responseData = Data()

    var callback: ((Data?, Error?) -> Void)

    init(completion: @escaping ((Data?, Error?) -> Void)) {
        self.callback = completion
    }

    // MARK: - URLSessionDelegate

    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("BinaryDelegate.URLSessionDelegate 1")
        DispatchQueue.main.async {
            self.callback(self.responseData, error)
        }
    }

    @available(iOS 7.0, *)
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("BinaryDelegate.URLSessionDelegate 2")
        completionHandler(.performDefaultHandling, nil)
    }

    @available(iOS 7.0, *)
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        print("BinaryDelegate.URLSessionDelegate 3")
    }

    // MARK: - URLSessionDataDelegate

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        let res = response as! HTTPURLResponse
        print("BinaryDelegate.URLSessionDataDelegate 1 -> completion response: \(res.statusCode)")
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        print("BinaryDelegate.URLSessionDataDelegate 2")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        print("BinaryDelegate.URLSessionDataDelegate 3")
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("BinaryDelegate.URLSessionDataDelegate 4 (appending data \(data.count))")
        responseData.append(data)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        print("BinaryDelegate.URLSessionDataDelegate 5 -> completion")
        completionHandler(nil)
    }

    // MARK: - URLSessionTaskDelegate (Parent protocol of NSURLSessionDataDelegate)

    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        print("BinaryDelegate.URLSessionTaskDelegate 1 -> completion")
        completionHandler(URLSession.DelayedRequestDisposition.continueLoading, request)
    }

    @available(iOS 11.0, *)
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        print("BinaryDelegate.URLSessionTaskDelegate 2")
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("BinaryDelegate.URLSessionTaskDelegate 3 -> completion")
        completionHandler(.performDefaultHandling, nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print("BinaryDelegate.URLSessionTaskDelegate 4")
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print("BinaryDelegate.URLSessionTaskDelegate 5 -> completion")
        completionHandler(nil)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("BinaryDelegate.URLSessionTaskDelegate 6")
    }

    @available(iOS 10.0, *)
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        print("BinaryDelegate.URLSessionTaskDelegate 7")

    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("BinaryDelegate.URLSessionTaskDelegate 8: \(error == nil ? "NO-ERROR" : error.debugDescription)" )
        // Change to main queue since URL session might have been running somewhere else
        DispatchQueue.main.async {
            self.callback(self.responseData, error)
        }
    }

}
