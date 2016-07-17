//
//  PreferencesWindow.swift
//  GoGong
//
//  Created by Sean Shadmand on 7/16/16.
//  Copyright © 2016 Etsy. All rights reserved.
//

import Foundation


struct Image: CustomStringConvertible {
    var url: String
    var description: String {
        return "\(url)"
    }
}

class GoGongAPI {
    
    func postImage(file: NSData, success: (Image) -> Void ) {
        
        let prefs = Preferences()
        
        print("Uploading to \(prefs.uploadUrl)")

        SRWebClient.POST(prefs.uploadUrl)
            
            .data(file, fieldName:"file", data:["key": prefs.apiKey])
            .send({(response:AnyObject!, status:Int) -> Void in
                
                    let json = response! as! Dictionary<String, String>
                    let newImage = Image(url: json["url"]!)
                    success(newImage)
                
                },failure:{(error:NSError!) -> Void in
                    print("Error posting image.")
            })
        
    }
    
    
    func imageFromJSONData(data: NSData) -> Image? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        var imageList = json["image"] as! [JSONDict]
        var imageDict = imageList[0]
        
        let image = Image(
            url: imageDict["url"] as! String
        )
        
        return image
    }
}