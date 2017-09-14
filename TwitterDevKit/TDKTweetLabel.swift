/*****************************************************************************
 *
 * FILE:	TDKTweetLabel.swift
 * DESCRIPTION:	TwitterDevKit: Tweet Label with Clickable Action
 * DATE:	Wed, Aug 23 2017
 * UPDATED:	Thu, Sep 14 2017
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * REFERENCED:  https://github.com/optonaut/ActiveLabel.swift
 * COPYRIGHT:	(c) 2017 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2017 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id$
 *
 *****************************************************************************/

import Foundation
import UIKit

public enum TDKActiveType
{
  case hashtag
  case media
  case url
  case mention
}

extension TDKActiveType: Hashable, Equatable
{
  public var hashValue: Int {
    switch self {
      case .hashtag: return -1
      case .media:   return -2
      case .url:     return -3
      case .mention: return -4
    }
  }

  public static func == (lhs: TDKActiveType, rhs: TDKActiveType) -> Bool {
    switch (lhs, rhs) {
      case (.hashtag, .hashtag): return true
      case (.media, .media):     return true
      case (.url, .url):         return true
      case (.mention, .mention): return true
      default: return false
    }
  }
}

public enum TDKActiveElementError: Error {
  case invalidEntity
}

public enum TDKActiveElement {
  case hashtag(TDKHashtag, String)
  case media(TDKMedia, String)
  case url(TDKURL, String)
  case mention(TDKUserMention, String)

  init(type: TDKActiveType, entity: Any) throws {
    switch type {
      case .hashtag:
        if let hashtag = entity as? TDKHashtag {
          self = .hashtag(hashtag, hashtag.text)
        }
        else {
          throw TDKActiveElementError.invalidEntity
        }
      case .media:
        if let media = entity as? TDKMedia, let displayUrl = media.displayUrl {
          self = .media(media, displayUrl)
        }
        else {
          throw TDKActiveElementError.invalidEntity
        }
      case .url:
        if let url = entity as? TDKURL, let urlStr = url.url {
          self = .url(url, urlStr)
        }
        else {
          throw TDKActiveElementError.invalidEntity
        }
      case .mention:
        if let mention = entity as? TDKUserMention, let name = mention.screenName {
          self = .mention(mention, name)
        }
        else {
          throw TDKActiveElementError.invalidEntity
        }
    }
  }
}


public typealias TDKTweetLabelActiveAttribute = ([String:Any], TDKActiveType, Bool) -> [String:Any]

public protocol TDKTweetLabelDelegate: class {
  func tweetLabel(_ label: TDKTweetLabel, didSelect element: TDKActiveElement)
}

public class TDKTweetLabel: UILabel
{
  public weak var delegate: TDKTweetLabelDelegate? = nil

  public var activeAttribute: TDKTweetLabelActiveAttribute? = nil

  public var lineSpacing: CGFloat = 0 {
    didSet { updateTextStorage() }
  }

  public var minimumLineHeight: CGFloat = 0 {
    didSet { updateTextStorage() }
  }

  public var tweet: TDKTweet? = nil {
    didSet { 
      clearActiveElements()
      text = parseTweet()
    }
  }

  fileprivate lazy var textStorage = NSTextStorage()
  fileprivate lazy var layoutManager = NSLayoutManager()
  fileprivate lazy var textContainer = NSTextContainer()

  fileprivate var heightCorrection: CGFloat = 0.0

  typealias ElementTuple = (range: NSRange, element: TDKActiveElement, type: TDKActiveType)
  fileprivate var selectedElement: ElementTuple?
  fileprivate var activeElements = [TDKActiveType:[ElementTuple]]()

  fileprivate var isCustomizing: Bool = false

  // MARK: - override UILabel properties
  override public var text: String? {
    didSet { updateTextStorage() }
  }

  override public var attributedText: NSAttributedString? {
    didSet { updateTextStorage() }
  }

  override public var font: UIFont! {
    didSet { updateTextStorage() }
  }

  override public var textColor: UIColor! {
    didSet { updateTextStorage() }
  }

  override public var textAlignment: NSTextAlignment {
    didSet { updateTextStorage() }
  }

  override public var numberOfLines: Int {
    didSet {
      textContainer.maximumNumberOfLines = numberOfLines
    }
  }

  override public var lineBreakMode: NSLineBreakMode {
    didSet {
      textContainer.lineBreakMode = lineBreakMode
    }
  }


  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .clear
    self.numberOfLines = 0
    self.lineBreakMode = .byWordWrapping
    self.font = UIFont.systemFont(ofSize: 16.0)

    textContainer.lineFragmentPadding = 0.0
    textContainer.lineBreakMode = lineBreakMode
    textContainer.maximumNumberOfLines = numberOfLines
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)

    prepareCopyable()
  }
}

extension TDKTweetLabel
{
  public override func drawText(in rect: CGRect) {
    let range = NSRange(location: 0, length: textStorage.length)

    textContainer.size = rect.size
    let newOrigin = textOrigin(in: rect)

    layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
    layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
  }

  fileprivate func textOrigin(in rect: CGRect) -> CGPoint {
    let usedRect = layoutManager.usedRect(for: textContainer)
    heightCorrection = (rect.size.height - usedRect.size.height) * 0.5
    let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
    return CGPoint(x: rect.origin.x, y: glyphOriginY)
  }
}

extension TDKTweetLabel
{
  fileprivate func updateTextStorage() {
    if isCustomizing { return }
    guard let attributedText = attributedText, attributedText.length > 0 else {
      clearActiveElements()
      textStorage.setAttributedString(NSAttributedString())
      setNeedsDisplay()
      return
    }

    let mutAttrString = addParagraphStyle(attributedText)

    addLanguageAttribute(mutAttrString)

    addLinkAttribute(mutAttrString)
    textStorage.setAttributedString(mutAttrString)
    isCustomizing = true
    text = mutAttrString.string
    isCustomizing = false
    setNeedsDisplay()
  }

  fileprivate func addParagraphStyle(_ attrString: NSAttributedString) -> NSMutableAttributedString {
    let mutAttrString = NSMutableAttributedString(attributedString: attrString)

    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)

    let paragraphStyle = attributes[NSParagraphStyleAttributeName] as? NSMutableParagraphStyle ?? NSMutableParagraphStyle()
    paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
    paragraphStyle.alignment = textAlignment
    paragraphStyle.lineSpacing = lineSpacing
    paragraphStyle.minimumLineHeight = minimumLineHeight > 0 ? minimumLineHeight : self.font.pointSize * 1.14
    attributes[NSParagraphStyleAttributeName] = paragraphStyle
    mutAttrString.setAttributes(attributes, range: range)

    return mutAttrString
  }

  fileprivate func addLinkAttribute(_ mutAttrString: NSMutableAttributedString) {
    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)

    attributes[NSFontAttributeName] = font!
    attributes[NSForegroundColorAttributeName] = textColor
    mutAttrString.addAttributes(attributes, range: range)

    for (type, elements) in activeElements {
      attributes = linkAttributes(attributes, activeType: type, isSelected: false)
      if let activeAttribute = activeAttribute {
        attributes = activeAttribute(attributes, type, false)
      }
      for element in elements {
        mutAttrString.setAttributes(attributes, range: element.range)
      }
    }
  }

  fileprivate func linkAttributes(_ attributes: [String:Any], activeType: TDKActiveType, isSelected: Bool) -> [String:Any] {
    let prettyColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    var attrs = attributes

    if isSelected {
      attrs[NSForegroundColorAttributeName] = UIColor.lightGray
    }
    else {
      attrs[NSForegroundColorAttributeName] = prettyColor
    }
    switch activeType {
      case .hashtag:
        break
      case .mention:
        break
      case .url, .media:
        if !isSelected {
          attrs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue
        }
    }
    return attrs
  }

  fileprivate func clearActiveElements() {
    selectedElement = nil
    for (type, _) in activeElements {
      activeElements[type]?.removeAll()
    }
  }
}

extension TDKTweetLabel
{
  fileprivate func addLanguageAttribute(_ mutAttrString: NSMutableAttributedString) {
    var range = NSRange(location: 0, length: 0)
    var attributes = mutAttrString.attributes(at: 0, effectiveRange: &range)

    var lang: String = Locale.preferredLanguages[0]
    lang = lang.substring(to: lang.index(lang.startIndex, offsetBy: 2))
    attributes[kCTLanguageAttributeName as String] = lang // 禁則処理を言語に合わせる
    mutAttrString.setAttributes(attributes, range: range)
  }

  fileprivate func prettyReplaced(_ text: String) -> String {
    var newText = text
    // XXX: 特定のクライアントの投稿のエスケープ処理に対応
    newText = newText.replacingOccurrences(of: "&amp;", with: "&")
    newText = newText.replacingOccurrences(of: "&lt;", with: "<")
    newText = newText.replacingOccurrences(of: "&gt;", with: ">")
    return newText
  }

  fileprivate func parseTweet() -> String {
    guard let tweet = self.tweet, let text = tweet.displayedText else { return "" }

    let tweetText = prettyReplaced(text)
    let tweetLength = tweetText.characters.count

    let substring = { (_ indices: [Int]) -> (String, Range<String.Index>)? in
      if let st = indices.first, let ed = indices.last {
        /*
         * XXX:
         * swift - Cannot increment beyond endIndex - Stack Overflow
         * https://stackoverflow.com/questions/41468014/cannot-increment-beyond-endindex
         */
        guard ed <= tweetLength else { return nil }
        let lo = tweetText.index(tweetText.startIndex, offsetBy: st)
        let hi = ed == tweetLength
               ? tweetText.endIndex
               : tweetText.index(tweetText.startIndex, offsetBy: ed)
        let rn = lo ..< hi
        let sb = tweetText.substring(with: rn)
        return (sb, rn)
      }
      return nil
    }

    let paranoiacHashtagCheck = { (_ text: String, _ hashtag: String) -> Bool in
      guard text.range(of: hashtag) != nil else { return false }
      if text == "#" + hashtag { return true }
      return text == "＃" + hashtag
    }

    if let hashtags = tweet.entities?.hashtags {
      var elements = [ElementTuple]()
      let addHashtag = {
        (_ hashtag: TDKHashtag, _ range: Range<String.Index>) -> Void in
        let nsRange = tweetText.nsRange(from: range)
        do {
          let element = try TDKActiveElement(type: .hashtag, entity: hashtag)
          elements.append((range: nsRange, element: element, type: .hashtag))
        }
        catch let error {
          dump(error)
        }
      }
      for hashtag in hashtags {
        if let (text, range) = substring(hashtag.indices),
           paranoiacHashtagCheck(text, hashtag.text) {
          addHashtag(hashtag, range)
        }
        else if let range = tweetText.range(of: "#" + hashtag.text, options: [ .literal, .diacriticInsensitive ]) {
          addHashtag(hashtag, range)
        }
      }
      activeElements[.hashtag] = elements
    }

    let paranoiacMentionCheck = { (_ text: String, _ mention: String) -> Bool in
      guard text.range(of: mention) != nil else { return false }
      if text == "@" + mention { return true }
      return text == "＠" + mention
    }

    if let mentions = tweet.entities?.userMentions {
      var elements = [ElementTuple]()
      let addMention = {
        (_ mention: TDKUserMention, _ range: Range<String.Index>) -> Void in
        let nsRange = tweetText.nsRange(from: range)
        do {
          let element = try TDKActiveElement(type: .mention, entity: mention)
          elements.append((range: nsRange, element: element, type: .mention))
        }
        catch let error {
          dump(error)
        }
      }
      for mention in mentions {
        if let name = mention.screenName {
          if let (text, range) = substring(mention.indices),
             paranoiacMentionCheck(text, name) {
            addMention(mention, range)
          }
          else if let range = tweetText.range(of: "@" + name, options: [ .literal, .diacriticInsensitive, .widthInsensitive ]) {
            addMention(mention, range)
          }
        }
      }
      activeElements[.mention] = elements
    }

    if let urls = tweet.entities?.urls {
      var elements = [ElementTuple]()
      for url in urls {
        if let urlStr = url.url {
          if let range = tweetText.range(of: urlStr) {
            let nsRange = tweetText.nsRange(from: range)
            do {
              let element = try TDKActiveElement(type: .url, entity: url)
              elements.append((range: nsRange, element: element, type: .url))
            }
            catch let error {
              dump(error)
            }
          }
        }
      }
      activeElements[.url] = elements
    }

    if let media = tweet.extendedEntities?.media ?? tweet.entities?.media {
      var elements = [ElementTuple]()
      for medium in media {
        if let urlStr = medium.url {
          if let range = tweetText.range(of: urlStr) {
            let nsRange = tweetText.nsRange(from: range)
            do {
              let element = try TDKActiveElement(type: .media, entity: medium)
              elements.append((range: nsRange, element: element, type: .media))
            }
            catch let error {
              dump(error)
            }
          }
        }
      }
      activeElements[.media] = elements
    }

    return tweetText
  }
}

extension TDKTweetLabel
{
  @discardableResult
  fileprivate func onTouch(_ touch: UITouch) -> Bool {
    let location: CGPoint = touch.location(in: self)
    var avoidSuperCall = false

    switch touch.phase {
      case .began, .moved:
        if let element = element(at: location) {
          if element.range.location != selectedElement?.range.location ||
             element.range.length != selectedElement?.range.length {
            updateAttributesWhenSelected(false)
            selectedElement = element
            updateAttributesWhenSelected(true)
          }
          avoidSuperCall = true
        }
        else {
          updateAttributesWhenSelected(false)
          selectedElement = nil
        }
      case .ended:
        if let selectedElement = self.selectedElement {
          delegate?.tweetLabel(self, didSelect: selectedElement.element)

          DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            [unowned self] in
            self.updateAttributesWhenSelected(false)
            self.selectedElement = nil
          }
          avoidSuperCall = true
        }
      case .cancelled:
          updateAttributesWhenSelected(false)
          selectedElement = nil
      default:
        break
    }

    return avoidSuperCall
  }

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    hideMenuController()
    if onTouch(touch) { return }
    super.touchesBegan(touches, with: event)
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesMoved(touches, with: event)
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    if onTouch(touch) { return }
    super.touchesEnded(touches, with: event)
  }

  public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    onTouch(touch)
    super.touchesCancelled(touches, with: event)
  }

  fileprivate func element(at location: CGPoint) -> ElementTuple? {
    guard textStorage.length > 0 else { return nil }

    var correctLocation = location
    correctLocation.y -= heightCorrection
    let range = NSRange(location: 0, length: textStorage.length)
    let boundingRect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
    guard boundingRect.contains(correctLocation) else { return nil }

    let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
    for element in activeElements.map({ $0.1 }).joined() {
      let start = element.range.location
      let end   = start + element.range.length
      if index >= start && index <= end {
        return element
      }
    }

    return nil
  }

  fileprivate func updateAttributesWhenSelected(_ isSelected: Bool) {
    guard let selectedElement = self.selectedElement else { return }

    var attributes = textStorage.attributes(at: 0, effectiveRange: nil)
    let type = selectedElement.type

    attributes = linkAttributes(attributes, activeType: type, isSelected: isSelected)
    if let activeAttribute = self.activeAttribute {
      attributes = activeAttribute(attributes, type, isSelected)
    }

    textStorage.addAttributes(attributes, range: selectedElement.range)

    setNeedsDisplay()
  }
}

extension TDKTweetLabel
{
  func suitableContentSize(width: CGFloat, height: CGFloat) -> CGSize {
    guard let attributedText = self.attributedText, attributedText.length > 0 else {
      return CGSize(width: width, height: 8.0) // XXX: No text...
    }
    var range = NSRange(location: 0, length: 0)
    let attributes = attributedText.attributes(at: 0, effectiveRange: &range)
    let constraintSize = CGSize(width: width, height: height)
    return attributedText.string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
  }
}

/*
 * ios - Selectable UILabel contents - Stack Overflow
 * https://stackoverflow.com/questions/15188911/selectable-uilabel-contents
 */
extension TDKTweetLabel
{
  func prepareCopyable() {
    isUserInteractionEnabled = true

    let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    addGestureRecognizer(holdGesture)
  }

  func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began {
      becomeFirstResponder()
      let menu = UIMenuController.shared
      if !menu.isMenuVisible {
        menu.setTargetRect(bounds, in: self)
        menu.setMenuVisible(true, animated: true)
      }
    }
  }

  func hideMenuController() {
    let menu = UIMenuController.shared
    if menu.isMenuVisible {
      menu.setMenuVisible(false, animated: true)
    }
  }

  override public var canBecomeFirstResponder: Bool {
    return true
  }

  override public func copy(_ sender: Any?) {
    let menu = UIMenuController.shared
    let labelText = self.text ?? self.attributedText?.string
    if let copyedText = labelText {
      let clipboard = UIPasteboard.general
      clipboard.string = copyedText
    }
    menu.setMenuVisible(false, animated: true)
  }

  override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return action == #selector(UIResponderStandardEditActions.copy)
  }
}


extension TDKTweet
{
  /*
   * Upcoming changes to Tweets ? Twitter Developers
   * https://dev.twitter.com/overview/api/upcoming-changes-to-tweets
   * □ display_text_range: an array of two unicode code point indices,
   *    identifying the inclusive start and exclusive end of the displayable
   *    content of the Tweet.
   */
  var displayedText: String? {
    var retval: String? = self.text
    if let  text = self.fullText,
       let first = self.displayTextRange?.first,
       let  last = self.displayTextRange?.last {
       guard first < last else { return nil }
       let range = text.startIndex..<text.endIndex
      var chars: [String] = []
      var count = 0
      text.enumerateSubstrings(in: range, options: .byComposedCharacterSequences) {
        (substring, _, _, _) -> () in
        if let substring = substring {
          /*
           * XXX: 2017/09/13 (Wed)
           * first を利用すると mention 部分が省略される
           * よって、first は 0 からの処理とする
          if count >= first && count < last {
            chars.append(substring)
          }
          */
          if count >= 0 && count < last {
            chars.append(substring)
          }
          count += 1
        }
      }
      retval = chars.joined()
    }
    return retval
  }
}


/*
 * nsstring - NSRange to Range<String.Index> - Stack Overflow
 * https://stackoverflow.com/questions/25138339/nsrange-to-rangestring-index
 */
fileprivate extension String
{
  func nsRange(from range: Range<String.Index>) -> NSRange {
    let from = range.lowerBound.samePosition(in: utf16)
    let to = range.upperBound.samePosition(in: utf16)
    return NSRange(location: utf16.distance(from: utf16.startIndex, to: from),
                   length: utf16.distance(from: from, to: to))
  }
}

fileprivate extension String
{
  func range(from nsRange: NSRange) -> Range<String.Index>? {
    guard
      let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
      let to16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: utf16.endIndex),
      let from = from16.samePosition(in: self),
      let to = to16.samePosition(in: self)
      else { return nil }
    return from ..< to
  }
}
