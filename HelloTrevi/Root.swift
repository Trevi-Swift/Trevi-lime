//
//  Lime.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 1..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Lime

/*
    Cookie parser 
    Chunk encoding
    response refactoring (etag)
    mime type 


    all(get,post,put)

*/

import Trevi

public class Root{
    
    private let lime = Lime()
    private var router: Router!
    
    public init(){
        
        router = lime.router
        
        router.get("/") { req , res , next in
            res.render("index.ssp", args: ["title":"Trevi"])
        }
        
        router.get("/index") { req , res , next in
            res.write("index get")
            res.end()
        }

        router.post("double", MultiParty()) { (req, res, next) -> Void in
 
            for (k,v) in req.files {
                let file = v as! File
                print("\(k) , \(file.path)")
            }

            
            for (k,v) in req.body {
                print("\(k) , \(v)")
            }
            res.send("multipart parser middleware")
        }

        
        router.post("/index") { req , res , next in
            func ondata(data: String) {
                print(data)
            }
            func onend() {
                res.send("index post")
            }
            req.on("data", ondata)
            req.on("end", onend)
        }
        
        router.get("/redir") { req , res , next in
            res.redirect("http://127.0.0.1:8080/")
        }
        
        router.get("/trevi/:param1") { req , res , next in
            print("[GET] /trevi/:praram")
            res.send(req.params["param1"]!)
        }
    }
}

// To leave implementation order to use a module in lime to use.
extension Root: Require{
    public func export() -> Router {
        return self.router
    }
}

