//
//  PreferencesWindow.swift
//  GoGong
//
//  Created by Sean Shadmand on 7/16/16.
//  Copyright © 2016 Etsy. All rights reserved.
//

import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class Preferences {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var uploadUrl: String {
        get {
            return defaults.stringForKey("upload_url") ?? DEFAULT_UPLOAD_URL
        }
        set {
            defaults.setValue(newValue, forKey: "upload_url")
        }
    }
    
    var apiKey: String {
        get {
            return defaults.stringForKey("api_key") ?? ""
        }
        set {
            defaults.setValue(newValue, forKey: "api_key")
        }
    }
    
    
}


class PreferencesWindow: NSWindowController, NSWindowDelegate {
    var delegate: PreferencesWindowDelegate?
    @IBOutlet weak var uploadUrlField: NSTextField!
    @IBOutlet weak var apiKeyField: NSTextField!
    
    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
        
        uploadUrlField.stringValue = Preferences().uploadUrl

    }
    
    func windowWillClose(notification: NSNotification) {
        Preferences().uploadUrl = uploadUrlField.stringValue
        Preferences().apiKey = apiKeyField.stringValue
        delegate?.preferencesDidUpdate()
        print(Preferences().apiKey, Preferences().uploadUrl)
    }
    
}







