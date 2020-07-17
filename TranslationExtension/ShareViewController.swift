//
//  ShareViewController.swift
//  TranslationExtension
//
//  Created by 侯猛 on 2020/7/17.
//  Copyright © 2020 侯猛. All rights reserved.
//

import Cocoa
import Alamofire
import SnapKit

class ShareViewController: NSViewController {
    
    
    @IBOutlet weak var originalView: NSScrollView!
    @IBOutlet var originalTextView: NSTextView!
    
    @IBOutlet weak var translationView: NSScrollView!
    @IBOutlet var translationTextView: NSTextView!
    
    private var translationViewSuperLeftConstraint: Constraint!
    
    private var translationViewOriginalLeftConstraint: Constraint!
    
    private var appInfo: String = ""
    
    private var originalUpdateText: String = ""
    
    private var originalDetailText: String = ""
    
    private var translationUpdateText: String = ""
    
    private var translationDetailText: String = ""
    
    @IBOutlet weak var originalButton: NSButton!
    
    private var indicator: NSProgressIndicator!
    
    @IBOutlet weak var cancelButton: NSButton!
    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }
    
    override func loadView() {
        super.loadView()
        initializeView()
        addSubviewCustom()
        addConstraintCustom()
        addBindSignal()
    }
    
    
    private func initializeView() {
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments, let first = attachments.first {
            let _ = first.loadObject(ofClass: String.self) { [weak self] (url, error) in
                guard let self = self, let url = url else {
                    return
                }
                self.requestAppDetail(url: url)
            }
        } else {
            NSLog("No Attachments")
        }
    }
    
    
    private func addSubviewCustom() {
        originalTextView.backgroundColor = .clear
        originalTextView.isEditable = false
        originalTextView.font = NSFont(name: "AppleSDGothicNeo-Bold", size: 20)
        translationTextView.backgroundColor = .clear
        translationTextView.isEditable = false
        translationTextView.font = NSFont(name: "AppleSDGothicNeo-Bold", size: 20)
        indicator = NSProgressIndicator(frame: .zero)
        indicator.style = .spinning
        indicator.startAnimation(nil)
        view.addSubview(indicator)
    }
    
    
    private func addConstraintCustom() {
        originalView.snp.makeConstraints { (maker) in
            maker.left.top.equalToSuperview().inset(5)
            maker.width.equalToSuperview().dividedBy(2)
            maker.bottom.equalTo(cancelButton.snp.top).offset(-5)
        }
        translationView.snp.makeConstraints { (maker) in
            translationViewOriginalLeftConstraint = maker.left.equalTo(originalView.snp.right).constraint
        }
        translationViewOriginalLeftConstraint.deactivate()
        translationView.snp.makeConstraints { (maker) in
            maker.right.top.equalToSuperview().inset(5)
            maker.bottom.equalTo(originalView)
            translationViewSuperLeftConstraint = maker.left.equalToSuperview().inset(5).constraint
        }
        originalButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.bottom.equalToSuperview().inset(5)
        }
        cancelButton.snp.makeConstraints { (maker) in
            maker.right.equalToSuperview().inset(20)
            maker.bottom.equalToSuperview().inset(5)
        }
        indicator.snp.makeConstraints { (maker) in
            maker.width.height.equalTo(50)
            maker.center.equalToSuperview()
        }
    }
    
    
    private func addBindSignal() {
        
    }
    
    // 获取 app 信息
    private func requestAppDetail(url: String) {
        let url = "https://itunes.apple.com/\(url.area)/lookup?id=\(url.id)"
        print(url)
        Alamofire.AF.request(url, method: .post)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                guard response.error == nil else {
                    debugPrint("HTTP Request failed: \(response.error!)")
                    return
                }
                if let tuple = response.value as? [String: Any], let results = tuple["results"] as? [[String: Any]], let result = results.first {
                    self.appInfo = "AppID:\(result.stringForKey("trackId") ?? "")\nUpdate Time:\((result.stringForKey("currentVersionReleaseDate") ?? "").time)\nCurrentVersion:\(result.stringForKey("version") ?? "")\nPrice:\(result.stringForKey("currency") ?? "") -> \(result.stringForKey("formattedPrice") ?? "")\nbundleId:\(result.stringForKey("bundleId") ?? "")"
                    self.originalUpdateText = result.stringForKey("releaseNotes") ?? ""
                    self.originalDetailText = result.stringForKey("description") ?? ""
                    self.translationAppUpdateDetail()
                }
        }
    }
    
    // 翻译 app 更新内容
    private func translationAppUpdateDetail() {
        let url = "https://translate.google.cn/translate_a/single"
        let header: HTTPHeaders = [
            "User-Agent": "iOSTranslate",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: Any] = [
            "dt": "t",
            "q": originalUpdateText,
            "tl": "zh-CN",
            "ie": "UTF-8",
            "sl": "auto",
            "client": "ia",
            "dj": "1"
        ]
        Alamofire.AF.request(url, method: .post, parameters: parameters, headers: header)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                guard response.error == nil else {
                    debugPrint("HTTP Request failed: \(response.error!)")
                    return
                }
                if let tuple = response.value as? [String: Any], let sentences = tuple["sentences"] as? [[String: Any]] {
                    let transTexts: [String] = sentences.compactMapCustom { (result, _) -> String? in
                        return result.stringForKey("trans")
                    }
                    self.translationUpdateText = transTexts.joined()
                    self.translationAppDetail()
                }
        }
    }
    
    // 翻译 app 描述内容
    private func translationAppDetail() {
        let url = "https://translate.google.cn/translate_a/single"
        let header: HTTPHeaders = [
            "User-Agent": "iOSTranslate",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: Any] = [
            "dt": "t",
            "q": originalDetailText,
            "tl": "zh-CN",
            "ie": "UTF-8",
            "sl": "auto",
            "client": "ia",
            "dj": "1"
        ]
        Alamofire.AF.request(url, method: .post, parameters: parameters, headers: header)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                guard response.error == nil else {
                    debugPrint("HTTP Request failed: \(response.error!)")
                    return
                }
                //                self.translationTextView.string = (result["description"] as? String) ?? ""
                if let tuple = response.value as? [String: Any], let sentences = tuple["sentences"] as? [[String: Any]] {
                    let transTexts: [String] = sentences.compactMapCustom { (result, _) -> String? in
                        return result.stringForKey("trans")
                    }
                    self.translationDetailText = transTexts.joined()
                    self.showResult()
                }
        }
        
    }
    
    private func showResult() {
        let originalAttributedString = NSMutableAttributedString(string: "#####更新详情#####\n\n\n\(originalUpdateText)\n\n\n#####软件详情#####\n\n\n\(originalDetailText)")
        originalAttributedString.addAttributeFont(NSFont(name: "AppleSDGothicNeo-Bold", size: 20))
        originalAttributedString.addAttributeColor(NSColor.red, rangeString: "#####更新详情#####")
        originalAttributedString.addAttributeFont(NSFont.systemFont(ofSize: 30), rangeString: "#####更新详情#####")
        originalAttributedString.addAttributeColor(NSColor.red, rangeString: "#####软件详情#####")
        originalAttributedString.addAttributeFont(NSFont.systemFont(ofSize: 30), rangeString: "#####软件详情#####")
        
        originalTextView.textStorage?.append(originalAttributedString)
        
        let translationAttributedString = NSMutableAttributedString(string: "\(self.appInfo) \n\n\n#####更新详情#####\n\n\n\(translationUpdateText)\n\n\n#####软件详情#####\n\n\n\(translationDetailText)")
        translationAttributedString.addAttributeFont(NSFont(name: "AppleSDGothicNeo-Bold", size: 20))
        translationAttributedString.addAttributeColor(NSColor.red, rangeString: "#####更新详情#####")
        translationAttributedString.addAttributeFont(NSFont.systemFont(ofSize: 30), rangeString: "#####更新详情#####")
        translationAttributedString.addAttributeColor(NSColor.red, rangeString: "#####软件详情#####")
        translationAttributedString.addAttributeFont(NSFont.systemFont(ofSize: 30), rangeString: "#####软件详情#####")
        translationTextView.textStorage?.append(translationAttributedString)
        
        indicator.isHidden = true
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
        
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
    }
    
    // 显示原文
    @IBAction func showOriginal(_ sender: NSButton) {
        if originalView.isHidden == true {
            originalView.isHidden = false
            translationViewSuperLeftConstraint.deactivate()
            translationViewOriginalLeftConstraint.activate()
        } else {
            originalView.isHidden = true
            translationViewOriginalLeftConstraint.deactivate()
            translationViewSuperLeftConstraint.activate()
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }
    
}

