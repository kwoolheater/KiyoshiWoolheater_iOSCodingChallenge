//
//  Client.swift
//  KiyoshiWoolheater_iOSCodeChallenge
//
//  Created by Kiyoshi Woolheater on 3/23/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import Foundation

class Client: NSObject {
    
    // create a session to call api through
    let sharedSession = URLSession.shared
    
    // call api and save data in PostArray to be displayed on tableview
    func callAPI(searchText: String?, completionHandlerForAPICall: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {
        var searchTerm: String?
        if searchText == nil { searchTerm = "funny" } else { searchTerm = (searchText as! String) }
        // create url request
        let url = URL(string: "http://www.reddit.com/r/\(searchTerm!)/.json")
        let urlRequest = URLRequest(url: url!)
        
        let task = sharedSession.dataTask(with: urlRequest) { data, response, error in
            // if an error occurs and print it
            func displayError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                print(userInfo)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                let userInfo = [NSLocalizedDescriptionKey : "There was a network error. Check your connection."]
                completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                let userInfo = [NSLocalizedDescriptionKey : "There was a network error. Check your connection."]
                completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: userInfo))
                return
            }
            
            // Parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]))
                return
            }
            
            for (index, value) in parsedResult {
                var result: NSDictionary
                if index ==  "error" {
                    completionHandlerForAPICall(false, NSError(domain: "Bad Search Term", code: 1, userInfo: [NSLocalizedDescriptionKey : "Bad Search Term"]))
                } else if index == "data" {
                    result = value as! NSDictionary
                    
                    for (key, value) in result {
                        var jsonTree: NSArray
                        if key as! String == "children" {
                            jsonTree = value as! NSArray
                            
                            for item in jsonTree {
                                
                                guard let post = item as? NSDictionary else {
                                    displayError("error in tree")
                                    completionHandlerForAPICall(false, NSError(domain: "Task", code: 1, userInfo: [NSLocalizedDescriptionKey : "error in tree"]))
                                    return
                                }
                                
                                for (key, value) in post {
                                    var postInfo: NSDictionary
                                    let newPost = Post.init()
                                    
                                    if key as! String == "data" {
                                        postInfo = value as! NSDictionary
                                    
                                        for (key, value) in postInfo {
                                            if key as! String == "author" {
                                                newPost.author = value as! String
                                            }
                                        
                                            if key as! String == "title" {
                                                newPost.title = value as! String
                                            }
                                        
                                            if key as! String == "thumbnail" && value as! String != "" {
                                                self.getImageData(url: value as! String, completionHandler: { success, data, error in
                                                    if success! {
                                                        if data != nil {
                                                            DispatchQueue.main.async {
                                                                newPost.thumbnail = data as! NSData
                                                            }
                                                        }
                                                    }
                                                })
                                            }
                                        
                                            if key as! String == "num_comments" {
                                                newPost.num_comments = value as! Int
                                            }
                                        
                                            if key as! String == "ups" {
                                                newPost.ups = value as! Int
                                            }
                                        
                                            if key as! String == "downs" {
                                                newPost.downs = value as! Int
                                            }
                                            
                                        }
                                        DispatchQueue.main.async {
                                            PostArray.sharedInstance().array.append(newPost)
                                            completionHandlerForAPICall(true, nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        task.resume()
        return task
    }
    
    func getImageData(url: String, completionHandler: @escaping (_ success: Bool?, _ imageData: Data?, _ errorString: String?) -> Void) {
        // Load the image data from the url provided
        let shared = URLSession.shared
        let url = URL(string: url)
        let request = URLRequest(url: url!)
        let task = shared.dataTask(with: request as URLRequest) { data, response, error in
            DispatchQueue.main.async {
                completionHandler(true, data, nil)
            }
        }
        task.resume()
    }

    // create a shared instance
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
        }
        return Singleton.sharedInstance
    }

}
