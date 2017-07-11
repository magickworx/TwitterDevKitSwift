/*****************************************************************************
 *
 * FILE:	TDKPrettyPrint.swift
 * DESCRIPTION:	TwitterDevKit: Pretty Formatter for Tweet
 * DATE:	Wed, Jun 14 2017
 * UPDATED:	Tue, Jul 11 2017
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
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

/*
 * NSMutableAttributedString の attributes 設定用
 * 以下のキーに attributes を設定する
 */
public enum TDKTweetAttribute: String {
  case   tweet = "tweet"
  case hashtag = "hashtag"
  case   media = "media"
  case     url = "url"
  case mention = "mention"
}

/*
 * XXX: 2017/06/14 (Wed)
 * 絵文字を含む文字列では addAttributes() の範囲が期待通りに機能しない。
 *
 * ios - End of NSAttributedString with emojis left unformatted
 *     - Stack Overflow
 *       https://stackoverflow.com/questions/31081213/end-of-nsattributedstring-with-emojis-left-unformatted
 */

// MARK: - Properties
extension TDKTweet
{
  public var prettyPrintedString: NSAttributedString? {
    let pretty = self.prettyPrinted()
    guard let tweet = pretty.text else { return nil }

#if     FULL_PRETTY_PRINTED
    let tweetString = NSMutableAttributedString(attributedString: tweet)
    let retString = NSMutableAttributedString()

    if let name = user?.name {
      let temp = String(format: "%@\n", name)
      let attributes: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14.0),
        NSForegroundColorAttributeName : UIColor.black
      ]
      retString.append(NSAttributedString(string: temp, attributes: attributes))
    }
    if let screenName = user?.screenName {
      let temp = String(format: "@%@\n", screenName)
      let attributes: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 14.0),
        NSForegroundColorAttributeName : UIColor.darkGray
      ]
      retString.append(NSAttributedString(string: temp, attributes: attributes))
    }

    retString.append(tweetString)

    if let dateString = createdAt?.localizedDateString {
      let temp = String(format: "\n%@", dateString)
      retString.append(NSAttributedString(string: temp))
    }
    return retString
#else
    return tweet
#endif
  }

  var displayedText: String? {
    var retval: String? = self.text
    if let  text = self.fullText,
       var first = self.displayTextRange?.first,
       var  last = self.displayTextRange?.last {
      let range = text.startIndex..<text.endIndex
      var chars : [String] = []
      text.enumerateSubstrings(in: range, options: .byComposedCharacterSequences) {
        (substring, _, _, _) -> () in
        if let substring = substring {
          chars.append(substring)
        }
      }
      // XXX: 絵文字が含まれるとおかしい値が含まれる場合もあるので強制補正
      if last > chars.count {
        last = chars.count
      }
       first = 0 // XXX: entities の範囲と食い違いが起こったので 0 固定
      retval = chars[first..<last].joined()
    }
    return retval
  }
}

// MARK: - Methods
extension TDKTweet
{
  public func prettyPrinted(with attributes: [TDKTweetAttribute:[String:Any]]? = nil) -> (text: NSAttributedString?, clickable: [String:[String:(NSRange,Any)]]?) {
    guard var text = self.displayedText else { return (nil, nil) }

    // XXX: 特定のクライアントの投稿のエスケープ処理に対応
    text = text.replacingOccurrences(of: "&amp;", with: "&")
    text = text.replacingOccurrences(of: "&lt;", with: "<")
    text = text.replacingOccurrences(of: "&gt;", with: ">")

    let tweetString = NSMutableAttributedString(string: text)
    let tweetLength = tweetString.length
    let range: NSRange = NSRange(location: 0, length: tweetLength)
    if let attributes = attributes?[.tweet] {
      tweetString.addAttributes(attributes, range: range)
    }
    else {
      var lang: String = Locale.preferredLanguages[0]
      lang = lang.substring(to: lang.index(lang.startIndex, offsetBy: 2))
      tweetString.addAttributes([
        kCTLanguageAttributeName as String : lang, // 禁則処理を言語に合わせる
        NSFontAttributeName : UIFont.systemFont(ofSize: 16.0)
      ], range: range)
    }

    /*
     * XXX: ATTENTION!!!
     * entities の indices を利用すると絵文字が含まれている場合、
     * 位置がずれるので実際の文字列から NSRange を計算して利用する。
     */
    var clickable: [String:[String:(NSRange,Any)]] = [:]
    let prettyColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    if let hashtags = self.entities?.hashtags {
      var hashtagAttrs: [String:Any] = [
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 16.0),
        NSForegroundColorAttributeName : prettyColor
      ]
      if let attributes = attributes?[.hashtag] {
        hashtagAttrs = attributes
      }

      var hashmap: [String:(NSRange,Any)] = [:]
      for hashtag in hashtags {
        if let range = text.range(of: "#" + hashtag.text) {
          let nsRange = text.nsRange(from: range)
          tweetString.addAttributes(hashtagAttrs, range: nsRange)
          hashmap[hashtag.text] = (nsRange, hashtag)
        }
      }
      if hashmap.count > 0 {
        clickable["hashtag"] = hashmap
      }
    }

    if let mentions = self.entities?.userMentions {
      var mentionAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor
      ]
      if let attributes = attributes?[.mention] {
        mentionAttrs = attributes
      }

      var mentionmap: [String:(NSRange,Any)] = [:]
      for mention in mentions {
        if let name = mention.screenName {
          if let range = text.range(of: "@" + name) {
            let nsRange = text.nsRange(from: range)
            tweetString.addAttributes(mentionAttrs, range: nsRange)
            mentionmap[name] = (nsRange, mention)
          }
        }
      }
      if mentionmap.count > 0 {
        clickable["mention"] = mentionmap
      }
    }

    if let urls = self.entities?.urls {
      var urlAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      if let attributes = attributes?[.url] {
        urlAttrs = attributes
      }

      var urlmap: [String:(NSRange,Any)] = [:]
      for url in urls {
        if let urlStr = url.url {
          if let range = text.range(of: urlStr) {
            let nsRange = text.nsRange(from: range)
            tweetString.addAttributes(urlAttrs, range: nsRange)
            urlmap[urlStr] = (nsRange, url)
          }
        }
      }
      if urlmap.count > 0 {
        clickable["url"] = urlmap
      }
    }

    var entities: TDKEntities? = nil
    if let extendedEntities = self.extendedEntities {
      entities = extendedEntities
    }
    else if let theEntities = self.entities {
      entities = theEntities
    }
    if let media = entities?.media {
      var mediaAttrs: [String:Any] = [
        NSForegroundColorAttributeName : prettyColor,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
      ]
      if let attributes = attributes?[.media] {
        mediaAttrs = attributes
      }

      var mediamap: [String:(NSRange,Any)] = [:]
      for medium in media {
        if let urlStr = medium.url, let displayUrl = medium.displayUrl {
          if let range = text.range(of: urlStr) {
            let nsRange = text.nsRange(from: range)
            tweetString.addAttributes(mediaAttrs, range: nsRange)
            mediamap[displayUrl] = (nsRange, medium)
          }
        }
      }
      if mediamap.count > 0 {
        clickable["media"] = mediamap
      }
    }

    return (tweetString, clickable)
  }
}

/*
 * How does String substring work in Swift 3 - Stack Overflow
 * https://stackoverflow.com/questions/39677330/how-does-string-substring-work-in-swift-3
 */
fileprivate extension String
{
  func index(from: Int) -> Index {
    return self.index(startIndex, offsetBy: from)
  }

  // let str = "Hello, playground"

  // print(str.substring(from: 7)) // playground
  func substring(from: Int) -> String {
    let fromIndex = index(from: from)
    return substring(from: fromIndex)
  }

  // print(str.substring(to: 5)) // Hello
  func substring(to: Int) -> String {
    let toIndex = index(from: to)
    return substring(to: toIndex)
  }

  // print(str.substring(with: 7..<11)) // play
  func substring(with r: Range<Int>) -> String {
    let startIndex = index(from: r.lowerBound)
    let endIndex = index(from: r.upperBound)
    return substring(with: startIndex..<endIndex)
  }
}

/*
 * ios - How to know if two emojis will be displayed as one emoji?
 *     - Stack Overflow
 * https://stackoverflow.com/questions/39104152/how-to-know-if-two-emojis-will-be-displayed-as-one-emoji
 */
fileprivate extension String
{
  var composedCharacterCount: Int {
    var count = 0
    enumerateSubstrings(in: startIndex..<endIndex, options: .byComposedCharacterSequences) {
      (_, _, _, _) in count += 1
    }
    return count
  }

  var isSingleComposedCharacter: Bool {
    return rangeOfComposedCharacterSequence(at: startIndex) == startIndex..<endIndex
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
