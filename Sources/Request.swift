//
//  Request.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi


// Currently, you don't use this class, but will use the next.
public class Request{
    
    public var request: IncomingMessage!
    
    public var socket: Socket{
        get{
            return request.socket
        }
        set{
            request.socket = newValue
        }
    }
    
    public var connection: Socket! {
        get{
            return request.socket
        }
        set{
            request.socket = newValue
        }
    }
    
    // HTTP header
    public var header: [ String: String ]!{
        get{
            return request.header
        }
        set{
            request.header = newValue
        }
    }

    
    public var httpVersionMajor: String {
        get{
            return request.httpVersionMajor
        }
        set{
            request.httpVersionMajor = newValue
        }
    }

    
    public var httpVersionMinor: String {
        get{
            return request.httpVersionMinor
        }
        set{
            request.httpVersionMinor = newValue
        }
    }

    
    public var version : String{
        return request.version
    }

    
    public var method: HTTPMethodType!{
        get{
            return request.method
        }
        set{
            request.method = newValue
        }
    }

    
    // Seperated path by component from the requested url
    public var pathComponent: [String] {
        get{
            return request.pathComponent
        }
        set{
            request.pathComponent = newValue
        }
    }
    
    // Qeury string from requested url
    // ex) /url?id="123"
    public var query: [ String: String ]!{
        get{
            return request.query
        }
        set{
            request.query = newValue
        }
    }

    
    public var path: String {
        get{
            return request.path
        }
        set{
            request.path = newValue
        }
    }

    
    public var hasBody: Bool! {
        get{
            return request.hasBody
        }
        set{
            request.hasBody = newValue
        }
    }

    
    //response only
    public var statusCode: String!{
        get{
            return request.statusCode
        }
        set{
            request.statusCode = newValue
        }
    }

    public var client: AnyObject!{
        get{
            return request.client
        }
        set{
            request.client = newValue
        }
    }

    public func on(name: String, _ emitter: Any){
        request.on(name, emitter)
    }

    public func emit(name: String, _ arguments : AnyObject...){
        // ## Emergency Hotfix ##
        //request.emit(name, arguments)
    }
    
    // for lime (not fixed)
    public var baseUrl: String! = ""
    public var route: AnyObject! = nil
    public var originUrl: String! = ""
    public var params:[String: String]! = [String: String]()
    public var json: [String: String]! = [String: String]()
    public var body: [String: String]! = [String: String]()
    public var bodyText: String! = ""
    
    public var files: [String: File]!
    
    public var app: AnyObject!
    
    public var startTime: NSDate
    
    //server only
    public var url: String!{
        get{
            return request.url
        }
        set{
            request.url = newValue
        }
    }
    
    
    public init(request: IncomingMessage) {
        self.request = request
        self.startTime = NSDate ()
        query = [String:String]()
    }
    
}


