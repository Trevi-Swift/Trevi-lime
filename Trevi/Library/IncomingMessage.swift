//
//  IncomingMessage.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 3..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation


public class IncomingMessage: StreamReadable{
    
    public var socket: Socket!
    
    public var connection: Socket!
    
    // HTTP header
    public var header: [ String: String ]!
    
    public var httpVersionMajor: String = "1"
    
    public var httpVersionMinor: String = "1"
    
    public var version : String{
        return "\(httpVersionMajor).\(httpVersionMinor)"
    }
    
    public var method: HTTPMethodType!
    
    // Seperated path by component from the requested url
    public var pathComponent: [String] = [ String ] ()
    
    // Qeury string from requested url
    // ex) /url?id="123"
    public var query = [ String: String ] ()
    
    public var path = ""
    
    public var hasBody: Bool!
    
    // for lime (not fixed)
    public var baseUrl: String! = ""
    public var route: AnyObject!
    public var originUrl: String! = ""
    public var params: [String: String]!
    public var json: [String: String]!
    public var body: [String: String]!
    public var bodyText: String!
    
    public var files: [String: File]!
    
    public var app: AnyObject!
    
    public let startTime: NSDate
    
    //server only
    public var url: String!{
        didSet{            
            originUrl = url
        }
    }
    
    
    //response only
    public var statusCode: String!
    public var client: AnyObject!
    
    init(socket: Socket){
        startTime = NSDate ()
        super.init()
        self.socket = socket
        self.connection = socket
        self.client = socket
    }
    
    deinit{
        socket = nil
        connection = nil
        client = nil
    }
    
    public override func _read(n: Int) {
        
    }
}
