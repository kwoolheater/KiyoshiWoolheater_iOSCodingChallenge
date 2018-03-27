//
//  Post.swift
//  KiyoshiWoolheater_iOSCodeChallenge
//
//  Created by Kiyoshi Woolheater on 3/23/18.
//  Copyright © 2018 Kiyoshi Woolheater. All rights reserved.
//

import Foundation

class Post: NSObject {
    var title: String!
    var author: String!
    var thumbnail: NSData?
    var num_comments: Int!
    var ups: Int!
    var downs: Int!
}

class PostArray: NSObject {
    var array = [Post]()
    
    class func sharedInstance() -> PostArray {
        struct Singleton {
            static var sharedInstance = PostArray()
        }
        return Singleton.sharedInstance
    }
}
