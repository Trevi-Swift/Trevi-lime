//
//  Logger.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2016. 1. 5..
//  Copyright © 2016 Trevi Community. All rights reserved.
//

import Foundation
import Trevi
import TreviSys

public typealias LoggerProccessor = (Request, Response) -> String
public var funcTbl: [String : LoggerProccessor] = [
    "http-version"  : log_http_version,
    "response-time" : log_response_time,
    "remote-addr"   : log_remote_addr,
    "date"          : log_date,
    "method"        : log_method,
    "url"           : log_url,
    "referrer"      : log_referrer,
    "user-agent"    : log_user_agent,
    "status"        : log_status
]

/**
 *
 * A Middleware for logging client connection.
 *
 */
public class Logger: Middleware {
    
    public var name: MiddlewareName
    public let format: String
    public let output: FileSystem.WriteStream?
    
    public init (format: String) {
        name = .Logger
        
        switch (format) {
        case "default":
            self.format = ":remote-addr - - [ :date ] \":method :url HTTP/:http-version\" :status :res[content-length] \":referrer\" \":user-agent\""
        case "short":
            self.format = ":remote-addr - :method :url HTTP/:http-version :status :res[content-length] - :response-time ms"
        case "tiny":
            self.format = ":method :url :status :res[content-length] - :response-time ms"
        default:
            self.format = format
        }
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        self.output = FileSystem.WriteStream(path: __dirname + "/lime_\(formatter.stringFromDate(NSDate())).log")
    }
    
    deinit {
    }
    
    public func handle(req: Request, res: Response, next: NextCallback?) -> () {
        res.onFinished = requestLog
        next!()
    }
    
    /**
     *
     * Make log with the format.
     *
     * - Parameter response: Can be a source to make a log and also be a
     * destination.
     *
     */
    private func requestLog(response res: Response) {
        let log = compileLog(self, req: res.req, res: res)
        print(log, terminator: "")
        output?.writeData(log.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}

private func compileLog(logger: Logger, req: Request, res: Response) -> String {
    var isCompiled = false
    var compiled = String(logger.format)
    
    for tokens in searchWithRegularExpression(logger.format, pattern: ":res\\[(.*?)\\]", options: [ .CaseInsensitive ]) {
        for type in HttpHeaderType.allValues where type.rawValue.lowercaseString == tokens["$1"]!.text.lowercaseString {
            guard let logPiece : String = res.header[ type.rawValue ] else {
                compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokens["$1"]!.text)]", withString: "" )
                continue
            }
            
            compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokens["$1"]!.text)]", withString: logPiece )
            isCompiled = true
        }
    }
    
    for tokens in searchWithRegularExpression(logger.format, pattern: ":([A-z0-9\\-]*)", options: [ .CaseInsensitive ]) {
        // get function by token
        guard let tokenFunc = funcTbl[tokens["$1"]!.text.lowercaseString] else {
            compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokens["$1"]!.text)", withString: "" )
            continue
        }
        
        compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokens["$1"]!.text)", withString: tokenFunc(req, res) )
        isCompiled = true
    }
    
    return isCompiled ? compiled + "\n" : ""
}

private func log_http_version ( req: Request, res: Response ) -> String {
    return req.version
}

private func log_response_time ( req: Request, res: Response ) -> String {
    let elapsedTime = Double( res.startTime.timeIntervalSinceDate( req.startTime ) )
    return "\(elapsedTime * 1000)"
}

private func log_remote_addr ( req: Request, res: Response ) -> String {
    guard let addr = getEndpointFromSocketAddress(Tcp.getPeerName(uv_tcp_ptr(req.socket.handle))) else {
        return ""
    }
    return addr.host
}

private func log_date ( req: Request, res: Response ) -> String {
    return getCurrentDatetime()
}

private func log_method ( req: Request, res: Response ) -> String {
    return req.method.rawValue
}

private func log_url ( req: Request, res: Response ) -> String {
    return req.url
}

private func log_referrer ( req: Request, res: Response ) -> String {
    if let referer = req.header["referer"] {
        return referer
    } else if let referrer = req.header["referrer"] {
        return referrer
    } else {
        return ""
    }
}

private func log_user_agent ( req: Request, res: Response ) -> String {
    if let agent = req.header["user-agent"] {
        return agent
    } else {
        return ""
    }
}

private func log_status ( req: Request, res: Response ) -> String {
    return "\(res.statusCode)"
}