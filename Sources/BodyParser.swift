//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi



/*
    This class is the middleware as one of the most important
    Consisting of many ways is easily allows us to write the user body.
    Now Support Json, Text, urlencoded parser
*/


public class BodyParser: Middleware{

    public var name  = MiddlewareName.BodyParser
    
    public init(){
        
    }
    
    public func handle(req: Request, res: Response, next: NextCallback?) {
        
    }
    
    public static func getBody(req: Request, _ cb: (body: String)->()){
        
        var body: NSMutableData = NSMutableData()
        func ondata(dt : NSData){
            body.appendData(dt)
        }
        
        func onend(){
            cb(body:  String(data: body, encoding: NSASCIIStringEncoding)!)
        }
        req.on("data", ondata)
        req.on("end", onend)
    }
    
    public static func read(req: Request, _ next: NextCallback?, parse: ((req: Request,  next: NextCallback ,  body: String!)->())){
        getBody(req) { body in
            parse(req: req, next: next!, body: body)
            
        }
    }
    
    public static func urlencoded() -> LimeCallback{
        func parse(req: Request, _ next: NextCallback? , _ bodyData: String!){
            var body = bodyData
            if body != nil {
                
                if body.containsString(CRLF){
                    body.removeAtIndex(body.endIndex.predecessor())
                }
                var resultBody = [String:String]()
                for component in body.componentsSeparatedByString("&") {
                    let trim = component.componentsSeparatedByString("=")
                    resultBody[trim.first!] = trim.last!
                }
                req.body = resultBody
            
                next!()
            }else {
                
            }
        }
        
        func urlencoded(req: Request, res: Response, next: NextCallback?) {
            guard req.header[Content_Type] == "application/x-www-form-urlencoded" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }

            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }
            
            read(req, next!,parse: parse)
        }
        return urlencoded

    }
    
    
    public static func json() -> LimeCallback {
        
        func parse(req: Request, _ next: NextCallback? , _ body: String!){
            do {
                
                let data = body.dataUsingEncoding(NSUTF8StringEncoding)
                let result = try NSJSONSerialization.JSONObjectWithData (data! , options: .AllowFragments ) as? [String:String]
                if let ret = result {
                    req.json = ret
                    return next!()
                }else {
                    // error handle
                }
            } catch {
                
            }
        }
        
        func jsonParser(req: Request, res: Response, next: NextCallback?) {
            guard req.header[Content_Type] == "application/json" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }

            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }

            read(req, next!,parse: parse)
        }
        return jsonParser
    }
    
    
    public static func text() -> LimeCallback{
        
        func parse(req: Request, _ next: NextCallback? , _ body: String!){

            if let ret = body {
                req.bodyText = ret
                return next!()
            }else {
                // error handle
            }
        }
        
        func textParser(req: Request, res: Response, next: NextCallback?) {
            guard req.header[Content_Type] == "text/plain" else {
                return next!()
            }
            
            guard req.hasBody == true else{
                return next!()
            }
            
            guard req.method == .POST || req.method == .PUT  else{
                return next!()
            }
            
            read(req, next!,parse: parse)
        }
        
        return textParser
    }
    
}




    
