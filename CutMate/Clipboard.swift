//
//  Clipboard.swift
//  CutMate
//
//  Created by Niklas on 06.12.23.
//

import Foundation
import Cocoa

class Clipboard {
    var myThread: Thread?
    private var last_clipboard_value: String?
    public var copies: Copies
    
    init(copies: Copies) {
        self.copies = copies
    }
    
    func startThread() {
        myThread = Thread(target: self, selector: #selector(entryPoint), object: nil)
        myThread?.start()
    }

    
    func clipboardChanged() {
        let clipboard_value = NSPasteboard.general.string(forType: .string)
        let copy = Copy(content: clipboard_value ?? "")
        
        DispatchQueue.main.async {
            if let index = self.copies.clipboard.firstIndex(where: { $0.content == clipboard_value }) {
                self.copies.clipboard.remove(at: index)

                self.copies.clipboard.insert(copy, at: 0)
            } else {
                self.copies.clipboard.insert(copy, at: 0)
            }
        }
    }
    
    func checkClipboardChange() {
        if (self.last_clipboard_value != NSPasteboard.general.string(forType: .string)) {
            clipboardChanged()
            self.last_clipboard_value = NSPasteboard.general.string(forType: .string);
        }
    }
    
    @objc private func entryPoint() {
        let runloop = RunLoop.current
        
        last_clipboard_value = NSPasteboard.general.string(forType: .string)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.checkClipboardChange()
        }
        
        runloop.add(timer, forMode: .default)
        runloop.run()
    }
}
