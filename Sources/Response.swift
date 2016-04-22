////
////  Response.swift
////  Trevi
////
////  Created by LeeYoseob on 2015. 11. 23..
////  Copyright © 2015 Trevi Community. All rights reserved.
////
//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import TreviSys
import Trevi


// Currently, you don't use this class, but will use the next.
public protocol Sender{
    func send(data: AnyObject?) -> Bool
    func end () -> Bool
    func template() -> Bool
    func render ( filename: String, args: AnyObject? ) -> Bool
}

public class Response{

    private let response: ServerResponse
    
    public var req: Request!
    public let startTime: NSDate
    public var onFinished : ((Response) -> Void)?

    var socket: Socket!{
        get{
            return response.socket
        }
        set{
            response.socket = newValue
        }
    }

    public var connection: Socket!{
        get{
            return response.connection
        }
        set{
            response.connection = newValue
        }
    }

    
    public var header: [String: String]!{
        get{
            return response.header
        }
        set{
            response.header = newValue
        }
    }

    public var shouldKeepAlive: Bool{
        get{
            return response.shouldKeepAlive
        }
        set{
            response.shouldKeepAlive = newValue
        }
    }

    public var chunkEncoding: Bool {
        get{
            return response.chunkEncoding
        }
        set{
            response.chunkEncoding = newValue
        }
    }


    
    public var statusCode: Int!{
        set{
            response.statusCode = newValue
        }
        get{
            return response.statusCode
        }
    }
    
    init(response: ServerResponse) {
        startTime = NSDate ()
        onFinished = nil
        self.response = response
    }

    // Lime recommend using that send rather than using write
    public func send(data: String, encoding: String! = nil, type: String! = ""){
        response.write(data, encoding: encoding, type: type)
        
        endReuqstAndClean()
    }
    
    public func send(data: NSData, encoding: String! = nil, type: String! = ""){
        response.write(data, encoding: encoding, type: type)
        endReuqstAndClean()
    }
    
    public func send(data: [String : String], encoding: String! = nil, type: String! = ""){
        response.write(data, encoding: encoding, type: type)
        endReuqstAndClean()
    }
    
    public func end(){
        response.end()
    }
    
    public func writeHead(statusCode: Int, headers: [String:String] = [:]){
        response.writeHead(statusCode, headers: headers)
    }
    
    public func write(data: String, encoding: String! = nil, type: String! = ""){
        response.write(data,encoding: encoding ,type:  type)
    }
    
    public func write(data: NSData, encoding: String! = nil, type: String! = ""){
       response.write(data,encoding: encoding ,type:  type)
    }
    
    public func write(data: [String : String], encoding: String! = nil, type: String! = ""){
       response.write(data,encoding: encoding ,type:  type)
    }

    
    private func endReuqstAndClean(){
        response.end()
        onFinished?(self)
        if req.files != nil {
            for file in self.req.files.values{
                FSBase.unlink(path: file.path)
            }
        }
    }
    
    public func render(path: String, args: [String:String]? = nil) {
        if let app = req.app as? Lime, let render = app.setting["view engine"] as? Render {
            var entirePath = path
            #if os(Linux)
                if let abpath = app.setting["views"] as? StringWrapper {
                    entirePath = "\(abpath.string)/\(entirePath)"
                }
            #else
                if let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: path).lastPathComponent!, ofType: nil) {
                    entirePath = bundlePath
                }
            #endif
            
            if args != nil {
                render.render(entirePath, args: args!) { data in
                    self.response.write(data)
                }
            } else {
                render.render(entirePath) { data in
                    self.response.write(data)
                }
            }
        }
        onFinished?(self)
        response.end()
    }
    
    public func redirect(url: String){
        response.writeHead(302, headers: [Location:url])
        onFinished?(self)
        response.end()
    }
}

