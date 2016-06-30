//
//  SwiftServerPage.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi

/**
 *
 * A Middleware to compile a specific SSP(Swift Server Page) file and send the
 * data to client.
 *
 */
public class SwiftServerPage: Render {

    public init() {
    }
    
    /**
     *
     * Get a compiled result of a SSP(Swift Server Page) file from the specific
     * path with the argument.
     *
     * - Parameter path: A path where file that is read is located
     *
     * - Returns: A string initialized by compiled swift server page data from
     * the file specified by path.
     *
     */
    public func render(path: String, writer: ((String) -> Void)) {
        return render(path, args: [:], writer: writer)
    }
    
    /**
     *
     * Get a compiled result of a SSP(Swift Server Page) file from the specific
     * path with the argument.
     *
     * - Parameter path: A path where file that is read is located
     * - Parameter args: Arguments that will be using to compile SSP file.
     * - Parameter writer: Callback to send data to user.
     *
     * - Returns: A string initialized by compiled swift server page data from
     * the file specified by path.
     *
     */
    public func render(path: String, args: [String:String], writer: ((String) -> Void)) {
        let file = FileSystem.ReadStream(path: path)
        let buf = NSMutableData()
        
        file?.onClose() { handle in
            let swiftCodes = convertToSwift(from: String(data: buf, encoding: NSUTF8StringEncoding)!, with: args)
            compileSwift(path, code: swiftCodes, callback: writer)
        }
        
        file?.readStart() { error, data in
            buf.appendData(data)
        }
    }
}

/**
 *
 * Get the Swift source codes from the specific SSP(Swift Server Page) file.
 * In this process, the SSP codes is divided into HTML codes and Swift codes.
 * After that, the HTML codes is wrapped by `print` function. An wrapped HTML
 * codes are combined with Swift code again.
 *
 * - Parameter ssp: The original data of SSP file which will be converted to a
 * Swift source code file.
 * - Parameter args: The list of arguments which is used at compiling.
 *
 * - Returns: The Swift source codes which are converted from SSP file with
 * arguments.
 *
 */
private func convertToSwift(from ssp: String, with args: [String:String]) -> String {
    var swiftCode: String = ""
    for key in args.keys {
        swiftCode += "var \(key) = \"\(args[key]!)\"\n"
    }
    
    var startIdx = ssp.startIndex
    
    let searched = searchWithRegularExpression( ssp, pattern: "(<%=?)[ \\t\\n]*([\\w\\W]+?)[ \\t\\n]*%>", options: [.CaseInsensitive] )
    for dict in searched {
        let swiftTag, htmlTag: String
        
        if dict["$1"]!.text == "<%=" {
            swiftTag = "print(\(dict["$2"]!.text), terminator:\"\")"
        } else {
            swiftTag = dict["$2"]!.text
        }
        
        htmlTag = ssp[startIdx ..< ssp.startIndex.advancedBy ( dict["$0"]!.range.location )]
            .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
            .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
            .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )
        
        swiftCode += "print(\"\(htmlTag)\", terminator:\"\")\n\(swiftTag)\n"
        
        startIdx = ssp.startIndex.advancedBy ( dict["$0"]!.range.location + dict["$0"]!.range.length )
    }
    
    let htmlTag = ssp[startIdx ..< ssp.endIndex]
        .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
        .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
        .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )
    
    return (swiftCode + "print(\"\(htmlTag)\")\n")
}

/**
 *
 * Run a callback as an argument to the results of compiling input code.
 *
 * - Parameter path: The path where compiled Swift codes will be located.
 * - Parameter code: Source codes which will be compiled.
 * - Parameter callback: Callback to send data to user.
 *
 */
private func compileSwift(path: String, code: String, callback: ((String) -> Void)) {
    let timestamp = Int(NSDate().timeIntervalSince1970 * 1000)
    let compileFile = "/tmp/\(NSURL(fileURLWithPath: path).lastPathComponent!)\(timestamp).swift"
    
    let file = FileSystem.WriteStream(path: compileFile)
    file?.writeData(code.dataUsingEncoding(NSUTF8StringEncoding)!)
    
    #if os(Linux)
        if Glibc.system("bash -c \"source ~/.profile && swiftc \(compileFile) -o /tmp/ssp\(timestamp) && chmod +x /tmp/ssp\(timestamp)\"") == 0 {
            if Glibc.system("bash -c \"/tmp/ssp\(timestamp) > /tmp/ssp\(timestamp)_print\"") == 0 {
                let file = FileSystem.ReadStream(path: "/tmp/ssp\(timestamp)_print")
                let buf = NSMutableData()
                
                file?.onClose() { handle in
                    if let result = String(data: buf, encoding: NSUTF8StringEncoding)?
                        .stringByReplacingOccurrencesOfString ( "{@t}", withString: "\t" )
                        .stringByReplacingOccurrencesOfString ( "{@n}", withString: "\n" ) {
                            callback(result)
                            Glibc.remove("/tmp/ssp\(timestamp)_print")
                    }
                }
                
                file?.readStart() { error, data in
                    buf.appendData(data)
                }
            }
        }
    #else
        if Darwin.system("swiftc \(compileFile) -o /tmp/ssp\(timestamp)") == 0 {
            if Darwin.system("bash -c \"/tmp/ssp\(timestamp) > /tmp/ssp\(timestamp)_print\"") == 0 {
                let file = FileSystem.ReadStream(path: "/tmp/ssp\(timestamp)_print")
                let buf = NSMutableData()
                
                file?.onClose() { handle in
                    if let result = String(data: buf, encoding: NSUTF8StringEncoding)?
                        .stringByReplacingOccurrencesOfString ( "{@t}", withString: "\t" )
                        .stringByReplacingOccurrencesOfString ( "{@n}", withString: "\n" ) {
                            callback(result)
                            Darwin.remove("/tmp/ssp\(timestamp)_print")
                    }
                }
                
                file?.readStart() { error, data in
                    buf.appendData(data)
                }
            }
        }
    #endif
}
