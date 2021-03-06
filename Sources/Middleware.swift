//
//  Middleware.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi

public enum MiddlewareName: String {
    case Query           = "query"
    case Err             = "error"
    case Undefined       = "undefined"
    case Favicon         = "favicon"
    case BodyParser      = "bodyParser"
    case Logger          = "logger"
    case Json            = "json"
    case CookieParser    = "cookieParser"
    case Session         = "session"
    case SwiftServerPage = "swiftServerPage"
    case Trevi           = "trevi"
    case Router          = "router"
    case ServeStatic     = "serveStatic"
    // else...
}



/*

    Middleware is an easy and fast to using the server can offer the many functions.
    Should be implemented handle in order to use as middleware.
*/
public protocol Middleware{
    var name: MiddlewareName { get set }
    func handle(req: Request, res: Response, next: NextCallback?) -> ()
}
