//
//  main.swift
//  RemoveSimulators
//
//  Created by rick on 18/08/15.
//  Copyright © 2015 KF Interactive Gmbh. All rights reserved.
//

import Foundation


func getDeviceListOutput() -> String? {
    let task = NSTask()
    task.launchPath = "/usr/bin/xcrun"
    task.arguments = ["simctl", "list"]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
        return output as String
    } else {
        return String?()
    }
}

func deleteDeviceWithUuid(uuid: String) {
    let path = NSString(string: "~/Library/Developer/CoreSimulator/Devices").stringByExpandingTildeInPath.stringByAppendingFormat("/%@/data/Containers", uuid) as String
  
    if !NSFileManager.defaultManager().fileExistsAtPath(path) {
        print("deleting: \(uuid)")
        let task = NSTask()
        task.launchPath = "/usr/bin/xcrun"
        task.arguments = ["simctl", "delete", uuid]
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = NSString(data: data, encoding: NSUTF8StringEncoding) {
            print("-> \(output)")
        }
    } else {
        print("preserving \(uuid)")
    }
}

func matchesForRegexInText(regex: String, text: String) -> [String] {
    let regex = try! NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions.CaseInsensitive)
    let nsString = text as NSString
    let results = regex.matchesInString(text, options: [], range: NSMakeRange(0, nsString.length))
    return results.map { nsString.substringWithRange($0.rangeAtIndex(1))}
}

func deviceUuidsFromListOutput(output: String) -> [String] {
    let result = matchesForRegexInText("\\(([0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12})\\)\\s\\(Shutdown\\)", text: output)
    return result
}

if let output = getDeviceListOutput() {
    let uuids = deviceUuidsFromListOutput(output)
    
    for uuid in uuids {
        deleteDeviceWithUuid(uuid)
    }
}

