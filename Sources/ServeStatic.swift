//
//  ServeStatic.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 27..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi

/**
 A Middleware for serving static files in server like .css, .js, .html, etc.
 */
public class ServeStatic: Middleware {
    
    public var name: MiddlewareName
    private let basePath: String
    
    public init (path: String) {
        name = .ServeStatic
        
        if let last = path.characters.last where last == "/" {
            basePath = path[path.startIndex ..< path.endIndex.advancedBy(-1)]
        } else {
            basePath = path
        }
    }
    
    
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        var entirePath = req.url
    
        let type: String! = req.url.componentsSeparatedByString(".").last!
        
        guard let mType = type else {
            return next!()
        }
        
        let resultType = Mime.mimeType(mType)
        
        guard resultType.length() > 0 else {
            return next!()
        }
        
        
        #if os(Linux)
            entirePath = "\(basePath)/\(req.url)"
        #else
            if let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: req.url).lastPathComponent!, ofType: nil) {
                entirePath = bundlePath
            }
            let file = FileSystem.ReadStream(path: entirePath)
            let buf = NSMutableData()
            
            file?.onClose() { handle in
                return res.send(buf)
            }
            
            file?.readStart() { error, data in
                buf.appendData(data)
            }

        #endif
        
        next!()
    }
}
