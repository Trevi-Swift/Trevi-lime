//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import TreviSys
import Trevi

/*
    For Trevi users, allow routing and to apply middlewares without difficulty.
*/
public typealias LimeCallback = ( (Request, Response, NextCallback?) -> Void )


public class Lime : Routable {
    
    public var setting: [String: AnyObject]!
    
    public var router: Router{
        let r = self._router
        if let r = r {
            return r
        }
        return Router()
    }
    
    public override init () {
        super.init()
        lazyRouter()
    }
    
    private func lazyRouter(){
        guard _router == nil else {
            return
        }
        _router = Router()
        _router.use(md: Query())
    }
    
    public func use(middleware: Middleware) {
        _router.use(md: middleware)
    }
    
    #if os(Linux)
    public func set(name: String, _ val: String){
        if setting == nil {
            setting = [String: AnyObject]()
        }
        setting[name] = StringWrapper(string: val)
    }
    #endif
    
    public func set(name: String, _ val: AnyObject){
        if setting == nil {
            setting = [String: AnyObject]()
        }
        setting[name] = val
    }
    
    public func handle(req: Request, res: Response, next: NextCallback?){

        var done: NextCallback? = next
        
        if next == nil{
            func finalHandler() {
                res.statusCode = 404
                let msg = "Not Found 404"
                res.write(msg)
                res.end()
            }
            
            done = finalHandler
            res.req = req
            req.app = self
        }

        return self._router.handle(req,res: res,next: done!)
    }
}

// Needed to activate lime in the Trevi Fountain.
extension Lime: ApplicationProtocol {
    public func createApplication() -> HttpCallback {
        
        func innerHandle(incomingMessage: IncomingMessage, serverResponse: ServerResponse, next: NextCallback?){
        
            let res = Response(response: serverResponse)
            let req = Request(request: incomingMessage)
            
            self.handle(req, res: res, next: next)
            
        }
        
        return innerHandle
    }
}




