////
////  LimePrepare.swift
////  Trevi
////
////  Created by LeeYoseob on 2016. 2. 17..
////  Copyright © 2016년 LeeYoseob. All rights reserved.
////
//
//
//import Foundation
//import Trevi
//
//public class LimePrepare {
//    let prepare = PreparedHttp()
//    var eventListener: EventListener?
//    var totalLength = 0
//    
//    public init(){}
//    public convenience init(elistener: EventListener){
//        self.init()
//        eventListener = elistener
//    }
//    
//    public func appendData(info: EventInfo) ->Int {
//        
//        if let readData = info.params {
//            self.totalLength += readData.length
//            if readData.length > 0 {
//                let (contentLength, headerLength) = prepare.appendReadData(readData)
//                if contentLength > headerLength{
//                    self.totalLength -= headerLength
//                }
//                if self.totalLength >= contentLength || contentLength == 0{
//                    shootRequest(info.stream!)
//                }
//            }
//            return readData.length;
//        }
//        return 0
//    }
//    
//    private func reset(){
//        self.prepare.dInit()
//        self.totalLength = 0
//    }
//    
//    private func shootRequest(stream: SocketStream){
//        let httpClient = ClientSocket ( socket: stream )
//        //@Danger
//        MiddlewareManager.sharedInstance ().handleRequest(prepare.handleRequest(httpClient))
//        reset()
//    }
//}
