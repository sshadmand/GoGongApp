//
//  PreferencesWindow.swift
//  GoGong
//
//  Created by Sean Shadmand on 7/16/16.
//  Copyright © 2016 Etsy. All rights reserved.
//

import Cocoa
import WebKit
import AVFoundation


let DEFAULT_UPLOAD_URL = "http://localhost:8000/v1/api/upload/"
let DEFAULT_PLIST_DIR = "/Library/Preferences"
let DEFAULT_SCREENSHOT_PLIST = "com.apple.screencapture.plist"

class StatusMenuController: NSObject, DirectoryMonitorDelegate, PreferencesWindowDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    
    var sounds = [String: AVAudioPlayer]()

    var snapAppMenuItem: NSMenuItem!
    var screenShotPath = NSHomeDirectory().stringByAppendingString("/Desktop")
    var screenShotNSURL:NSURL?
    var currentShotIndex: Dictionary<String,Int> = [:]
    
    var preferencesWindow: PreferencesWindow!

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let goGongAPI = GoGongAPI()
    
    
    override func awakeFromNib() {
        setupMenu()
        updateScreenCapturePath()
        updateShotsIndex()
        print("\(self.currentShotIndex.count) existing shots")
        monitorScreenShots()
        

    }
    
    func setupMenu() {
        statusItem.menu = statusMenu
        let icon = NSImage(named: "statusIcon")
        icon?.template = true // best for dark mode
        
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
        preferencesWindow.delegate = self
        
        prepareSounds()

    }
    
    func prepareSounds() {
        do {
            let gongSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gong", ofType: "wav")!)
            let soundPlayer: AVAudioPlayer = try AVAudioPlayer(contentsOfURL: gongSound)
            soundPlayer.prepareToPlay()
            sounds["gong"] = soundPlayer
        } catch {
            print("Could not prepare audio.")
        }
    }
    
    func playGong() {
        let player = sounds["gong"]
        player!.currentTime = 0
        player!.play()
    }
    
    func getShotDirContents() -> [String] {
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(screenShotPath)!
        var dirContents: [String] = []
        
        while let element = enumerator.nextObject() as? String {
            if element.hasSuffix("png") {
                dirContents.append(element)
            }
        }
        
        return dirContents
    }
    
    func updateShotsIndex() {
        for element in getShotDirContents() {
            self.currentShotIndex[element] = 1
        }
        
    }
    
    func monitorScreenShots() {
        let dm = DirectoryMonitor(URL: screenShotNSURL!)
        dm.delegate = self
        dm.startMonitoring()
    }
    
    func updateScreenCapturePath() {
        
        let prefPath = NSHomeDirectory().stringByAppendingString(DEFAULT_PLIST_DIR)
        let screenShotPref = prefPath.stringByAppendingString("/\(DEFAULT_SCREENSHOT_PLIST)")
        let myDict = NSDictionary(contentsOfFile: screenShotPref)
        
        if (myDict != nil && myDict!["location"] != nil) {
            let newPath = myDict!["location"]! as! String
            let exists = NSFileManager.defaultManager().fileExistsAtPath(newPath)
            
            if exists {
                print("Changing screenshot path...")
                self.screenShotPath = newPath
            }
            
        }
        
        self.screenShotNSURL = NSURL(fileURLWithPath: screenShotPath)
        print(self.screenShotPath)
    }
    
    func directoryMonitorDidObserveChange(directoryMonitor: DirectoryMonitor) {
        
        let currContents = getShotDirContents()
        let index = self.currentShotIndex
        for element in currContents {
            if index[element] == nil {
                
                print("New file detected! \(element)")
                uploadNewScreenShot(element)
                updateShotsIndex()
                
            }
        }
        
    }
    
    func uploadNewScreenShot(filename: String) {
        let filePath = self.screenShotPath.stringByAppendingString("/\(filename)")
        let image: NSData = NSData(contentsOfFile: filePath)!
        goGongAPI.postImage(image, success: {
            newImage in
                
                PasteBoard().copyToBoard(newImage.url)
                self.playGong()
        
        })
    }
    
    func preferencesDidUpdate() {
        print("Updated")
    }
    
    @IBAction func preferencesClicked(sender: NSMenuItem) {
        preferencesWindow.showWindow(nil)
        preferencesWindow.window?.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
    }
    
    
    @IBAction func updateClicked(sender: NSMenuItem) {
        PasteBoard().list()
    }
    
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}
