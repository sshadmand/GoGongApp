//
//  PreferencesWindow.swift
//  GoGong
//
//  Created by Sean Shadmand on 7/16/16.
//  Copyright © 2016 Etsy. All rights reserved.
//

import Foundation
import AppKit

class PasteBoard: NSObject {
    
    func list() {
        
        let pasteboard = NSPasteboard.generalPasteboard()
        
        if let nofElements = pasteboard.pasteboardItems?.count {
            
            if nofElements > 0 {
                
                for element in pasteboard.pasteboardItems! {
                    print(element)
                }
                
            }
        }
    }
    
    func copyToBoard(value: String) {
        let pasteBoard = NSPasteboard.generalPasteboard()
        pasteBoard.clearContents()
        pasteBoard.setString(value, forType: NSStringPboardType)
        print("Copied \(value) to board.")
    }

}
