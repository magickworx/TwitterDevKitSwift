/*****************************************************************************
 *
 * FILE:	TDKTweetTableCell.swift
 * DESCRIPTION:	TwitterDevKit: Custom UITableViewCell with TDKTweet
 * DATE:	Thu, Jun 15 2017
 * UPDATED:	Wed, Oct 18 2017
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

open class TDKTweetTableCell: UITableViewCell
{
  open weak var delegate: TDKClickableActionDelegate? = nil

  let profileImageSize: CGFloat = TDKUser.profileImageSize

  let iconView: UIButton = UIButton(type: .custom)
  let nameLabel: UILabel = UILabel()
  let screenLabel: UILabel = UILabel()
  let tweetLabel: TDKTweetLabel = TDKTweetLabel()
  let dateLabel: UILabel = UILabel()

  let quotedView: UIView = UIView()
  let quotedName: UILabel = UILabel()
  let quotedScreen: UILabel = UILabel()
  let quotedTweet: TDKTweetLabel = TDKTweetLabel()
  let quotedMedia: UIImageView = UIImageView()

  let retweetLabel: UILabel = UILabel()
  let retweetDate: UILabel = UILabel()

  let mediaView: UIImageView = UIImageView()
  let playbackButton: UIButton = UIButton()
  let playbackLabel: UILabel = UILabel()

  var dataTask: URLSessionTask? = nil
  var mediaArray: [TDKMedia] = [] // 添付画像管理用

  open var tweet: TDKTweet? = nil {
    didSet {
      self.composeTweet()
    }
  }

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.selectionStyle = .none

    self.contentView.autoresizesSubviews = false
    self.contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight]

    self.contentView.addSubview(iconView)
    self.contentView.addSubview(nameLabel)
    self.contentView.addSubview(screenLabel)
    self.contentView.addSubview(tweetLabel)
    self.contentView.addSubview(dateLabel)

    self.quotedView.addSubview(quotedName)
    self.quotedView.addSubview(quotedScreen)
    self.quotedView.addSubview(quotedTweet)
    self.quotedView.addSubview(quotedMedia)
    self.contentView.addSubview(quotedView)

    self.contentView.addSubview(retweetLabel)
    self.contentView.addSubview(retweetDate)
    self.contentView.addSubview(mediaView)

    iconView.backgroundColor = .lightGray

    nameLabel.font = UIFont.boldSystemFont(ofSize: 15.0)

    screenLabel.font = UIFont.systemFont(ofSize: 15.0)
    screenLabel.textColor = .darkGray

    tweetLabel.font = UIFont.systemFont(ofSize: 18.0)
    tweetLabel.numberOfLines = 0
    tweetLabel.lineBreakMode = .byWordWrapping
    tweetLabel.textColor = UIColor(red: 43.0/255, green: 43.0/255, blue: 43.0/255, alpha: 1)
    tweetLabel.activeAttribute = { (attributes, activeType, isSelected) in
      let hexColor = { (_ hex: UInt32) -> UIColor in
        let   red: CGFloat = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((hex &   0xff00) >>  8) / 255.0
        let  blue: CGFloat = CGFloat((hex &     0xff)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
      }
      var attrs = attributes
      switch activeType {
        case .hashtag:
          if !isSelected {
            attrs[NSForegroundColorAttributeName] = hexColor(0x7f7fff)
          }
          break
        case .mention:
          if !isSelected {
            attrs[NSForegroundColorAttributeName] = hexColor(0xff7f7f)
          }
          break
        case .url:
          if !isSelected {
            attrs[NSForegroundColorAttributeName] = hexColor(0x7fbfff)
          }
        case .media:
          if !isSelected {
            attrs[NSForegroundColorAttributeName] = hexColor(0xffbf7f)
          }
          break
      }
      return attrs
    }

    dateLabel.font = UIFont.systemFont(ofSize: 15.0)
    dateLabel.textAlignment = .right

    quotedView.backgroundColor = .clear
    quotedName.font = UIFont.boldSystemFont(ofSize: 16.0)
    quotedScreen.font = UIFont.systemFont(ofSize: 16.0)
    quotedScreen.textColor = .darkGray
    quotedTweet.backgroundColor = .clear
    quotedTweet.font = UIFont.systemFont(ofSize: 16.0)
    quotedTweet.numberOfLines = 0
    quotedTweet.lineBreakMode = .byWordWrapping
    quotedMedia.clipsToBounds = true

    retweetLabel.font = UIFont.systemFont(ofSize: 14.0)
    retweetLabel.textColor = .lightGray
    retweetDate.font = UIFont.systemFont(ofSize: 14.0)
    retweetDate.textColor = .lightGray
    retweetDate.textAlignment = .right

    mediaView.clipsToBounds = true
    mediaView.addSubview(playbackButton)
    if let image = playbackIcon() {
      playbackButton.setBackgroundImage(image, for: .normal)
      playbackButton.frame = CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height)
      playbackButton.addTarget(self, action: #selector(playbackHandler), for: .touchUpInside)
    }
    playbackButton.isHidden = true

    playbackLabel.font = UIFont.systemFont(ofSize: 10.0)
    playbackLabel.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
    playbackLabel.textColor = .white
    playbackLabel.textAlignment = .center
    playbackLabel.isHidden = true
    mediaView.addSubview(playbackLabel)

    prepareTapHandlers()
  }

  deinit {
    if let dataTask = self.dataTask, dataTask.state != .completed {
      dataTask.cancel()
    }
  }

  open override func draw(_ rect: CGRect) {
    super.draw(rect)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    // 以下に必要なコードを記述する
  }

  func calculatesLayoutSubviews() -> CGSize {
    let  lineHeight: CGFloat = 24.0
    let   lineSpace: CGFloat = 4.0
    let    iconSize: CGFloat = profileImageSize
    let      margin: CGFloat = 8.0
    let   maxHeight: CGFloat = CGFloat(CGFloat.greatestFiniteMagnitude)

    let  width: CGFloat = self.contentView.frame.size.width
    var height: CGFloat = self.contentView.frame.size.height

    let m: CGFloat = margin
    let s: CGFloat = lineSpace
    var x: CGFloat = m
    var y: CGFloat = m
    var w: CGFloat = iconSize
    var h: CGFloat = w
    iconView.frame = CGRect(x: x, y: y, width: w, height: h)

    x = m + w + m
    w = width - x - m
    h = lineHeight
    nameLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += h

    screenLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += (h + s)

    let size = tweetLabel.suitableContentSize(width: w, height: maxHeight)
    h = ceil(size.height)
    tweetLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += (h + s)

    h = lineHeight
    dateLabel.frame = CGRect(x: x, y: y, width: w, height: h)
    y += h

    if let text = quotedTweet.text {
      if text.characters.count > 0 {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = quotedTweet.lineBreakMode
        let qw: CGFloat = w - m * 2.0
        let size = quotedTweet.suitableContentSize(width: qw, height: maxHeight)
        let qh: CGFloat = ceil(size.height + m * 2.0)
        h = lineHeight + lineHeight + s + qh + s
        if let quoted = self.tweet?.quotedStatus {
          if let media = getMedia(of: quoted), !media.isEmpty {
            let th = ceil(qw * 0.75)
            quotedMedia.frame = CGRect(x: m, y: h, width: qw, height: th)
            h += (th + m)
          }
          else {
            quotedMedia.frame = CGRect.zero
          }
        }
        quotedView.frame = CGRect(x: x, y: y, width: w, height: h)
        do {
          let tx = m
          var ty = m
          let tw = qw
          var th = lineHeight
          quotedName.frame = CGRect(x: tx, y: ty, width: tw, height: th)
          ty += th
          quotedScreen.frame = CGRect(x: tx, y: ty, width: tw, height: th)
          ty += th
          th = qh
          quotedTweet.frame = CGRect(x: tx, y: ty, width: tw, height: th)
        }
        y += h
      }
    }
    else {
      quotedView.frame = CGRect.zero
      quotedName.frame = CGRect.zero
      quotedScreen.frame = CGRect.zero
      quotedTweet.frame = CGRect.zero
      quotedMedia.frame = CGRect.zero
    }

    if let text = retweetLabel.text, text.characters.count > 0 {
      h = lineHeight - 4.0
      retweetLabel.frame = CGRect(x: x, y: y, width: w, height: h)
      y += h
    }
    else {
      retweetLabel.frame = CGRect.zero
    }

    if let text = retweetDate.text, text.characters.count > 0 {
      h = lineHeight - 4.0
      retweetDate.frame = CGRect(x: x, y: y, width: w, height: h)
      y += h
    }
    else {
      retweetDate.frame = CGRect.zero
    }

    if let tweet = self.tweet {
      var status: TDKTweet = tweet
      if let retweetedStatus = tweet.retweetedStatus {
        status = retweetedStatus
      }
      if let media = getMedia(of: status), !media.isEmpty {
        h = ceil(w * 0.75)
        mediaView.frame = CGRect(x: x, y: y, width: w, height: h)
        playbackButton.center = CGPoint(x: w * 0.5, y: h * 0.5)
        y += h

        if let videoInfo = media.first?.videoInfo, videoInfo.durationMillis > 0 {
          var sec = videoInfo.durationMillis / 1000
          let min = sec / 60
          sec = sec % 60
          playbackLabel.text = String(format: "%02zd:%02zd", min, sec)
          playbackLabel.frame = CGRect(x: 8.0, y: h - 28.0, width: 36.0, height: 24.0)
          playbackLabel.sizeToFit()
          playbackLabel.isHidden = false
          mediaView.backgroundColor = .black
        }
      }
      else {
        mediaView.frame = CGRect.zero
      }
    }

    y += 4.0 // 最下部の余白
    height = ceil(y)

    return CGSize(width: width, height: height)
  }

  open override func prepareForReuse() {
    iconView.setImage(nil, for: .normal)
    nameLabel.text = nil
    screenLabel.text = nil
    tweetLabel.text = nil
    dateLabel.text = nil

    quotedName.text = nil
    quotedScreen.text = nil
    quotedTweet.text = nil
    quotedMedia.image = nil

    retweetLabel.text = nil
    retweetDate.text = nil

    mediaView.image = nil
    mediaView.backgroundColor = .white
    playbackButton.isHidden = true
    playbackLabel.isHidden = true

    mediaArray.removeAll()

    super.prepareForReuse()
  }

  open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    return self.calculatesLayoutSubviews()
  }
}

// MARK: - Updates Content
extension TDKTweetTableCell
{
  func composeTweet() {
    guard let tweet = self.tweet else { return }

    var status: TDKTweet = tweet
    if let retweetedStatus = tweet.retweetedStatus {
      status = retweetedStatus

      if let name = tweet.user?.name {
        retweetLabel.text = "RT: \(name)"
      }
      if let date = tweet.createdAt?.localizedDateString {
        retweetDate.text = date
      }
    }
    tweetLabel.tweet = status

    if let quotedStatus = status.quotedStatus {
      if let user = quotedStatus.user {
        if let name = user.name {
          quotedName.text = name
        }
        if let screen = user.screenName {
          quotedScreen.text = "@" + screen
        }
        quotedTweet.tweet = quotedStatus
        quotedView.layer.borderWidth = 1.0
        quotedView.layer.borderColor = UIColor.lightGray.cgColor
        quotedView.layer.cornerRadius = 4.0
        quotedView.layer.masksToBounds = true
      }
      if let media = getMedia(of: quotedStatus) {
        self.fetchMedia(media, quoted: true)
      }
    }

    if let date = status.createdAt?.localizedDateString {
      dateLabel.text = date
    }

    if let name = status.user?.name {
      nameLabel.text = name
    }

    if let user = status.user, let screen = user.screenName {
      if user.verified {
        let text = NSMutableAttributedString(string: "@" + screen)
        let prettyColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        let attrs: [String:Any] = [
          NSForegroundColorAttributeName: prettyColor,
          NSFontAttributeName: screenLabel.font
        ]
        let checkmark: String = "\u{2714}\u{fe0e}"
        let verified = NSAttributedString(string: checkmark, attributes: attrs)
        text.append(verified)
        screenLabel.attributedText = text
      }
      else {
        screenLabel.text = "@" + screen
      }
    }

    if let user = status.user {
      fetchIcon(of: user)
    }

    if let media = getMedia(of: status) {
      self.fetchMedia(media)
    }

#if     false
    if let coordinates = status.coordinates, coordinates.type.lowercased() == "point" {
      dump(coordinates)
    }
    if let place = status.place {
      dump(place)
    }
#endif
    if status.possiblySensitive {
      print("sensitive")
    }
  }

  func getMedia(of status: TDKTweet) -> [TDKMedia]? {
    if let media = status.extendedEntities?.media {
      return media
    }
    else if let media = status.entities?.media {
      return media
    }
    return nil
  }
}

// MARK: - Tap Handler
/*
 * iphone - iOS: Find url in string and change the string to be clickable (tapable) - Stack Overflow
 *  https://stackoverflow.com/questions/16172236/ios-find-url-in-string-and-change-the-string-to-be-clickable-tapable
 */
extension TDKTweetTableCell
{
  func prepareTapHandlers() {
    tweetLabel.delegate = self
    quotedTweet.delegate = self

    iconView.addTarget(self, action: #selector(tapIconHandler), for: .touchUpInside)

    quotedMedia.isUserInteractionEnabled = true
    var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMediaHandler))
    quotedMedia.addGestureRecognizer(tapGesture)

    mediaView.isUserInteractionEnabled = true
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapMediaHandler))
    mediaView.addGestureRecognizer(tapGesture)
  }

  func tapIconHandler(sender: UIButton) {
    if var status = self.tweet {
      if let retweetedStatus = status.retweetedStatus {
        status = retweetedStatus
      }
      if let delegate = self.delegate, let tweet = self.tweet, let user = status.user {
        let action = TDKClickableActionType.icon(user)
        delegate.clickableAction(action, in: tweet)
      }
      else {
        dump(status.user)
      }
    }
  }

  func tapMediaHandler(gesture: UITapGestureRecognizer) {
    if var status = self.tweet {
      if let retweetedStatus = status.retweetedStatus {
        status = retweetedStatus
      }
      if let delegate = self.delegate, let tweet = self.tweet {
        if let view = gesture.view as? UIImageView, let image = view.image {
          let action = TDKClickableActionType.image(mediaArray, image)
          delegate.clickableAction(action, in: tweet)
        }
      }
      else {
        dump(status.entities?.media)
      }
    }
  }
}

extension TDKTweetTableCell: TDKTweetLabelDelegate
{
  public func tweetLabel(_ label: TDKTweetLabel, didSelect element: TDKActiveElement) {
    if let delegate = self.delegate, let tweet = self.tweet {
      var action: TDKClickableActionType
      switch element {
        case .hashtag(let hashtag, let text):
          action = .hashtag(hashtag, text)
        case .media(let media, let text):
          action = .media(media, text)
        case .url(let url, let text):
          action = .url(url, text)
        case .mention(let mention, let text):
          action = .mention(mention, text)
      }
      delegate.clickableAction(action, in: tweet)
    }
  }
}

// MARK: - Downloader
extension TDKTweetTableCell
{
  func fetchIcon(of user: TDKUser) {
    user.fetchProfileImage(completion: {
      (image: UIImage?, error: Error?) in
      guard error == nil else { return }
      if let image = image {
        DispatchQueue.main.async { [weak self] in
          if let weakSelf = self {
            weakSelf.iconView.setImage(image, for: .normal)
            weakSelf.iconView.backgroundColor = .clear
            let bounds = weakSelf.iconView.bounds
            let radius = bounds.width * 0.5
            let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
            let maskLayer = CAShapeLayer()
            maskLayer.path = maskPath.cgPath
            weakSelf.iconView.layer.mask = maskLayer
          }
        }
      }
    })
  }

  func fetchMedia(_ mediaArray: [TDKMedia], quoted: Bool = false) {
    let width = Float(self.contentView.bounds.size.width)
    for media in mediaArray {
      if let type = media.type?.lowercased(),
         let mediaUrlHttps = media.mediaUrlHttps {
        if type == "photo" || type == "video" || type == "animated_gif"{
          var   url: String = mediaUrlHttps
          var  size: String = "medium" // tiwtter default
          var ratio:  Float = Float(Float.greatestFiniteMagnitude)
          // 画面の横幅の比率に応じてサイズを自動決定するよ
          if let sizes = media.sizes {
            if let large = sizes.large {
              let w = Float(large.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "large"
                ratio = r
              }
            }
            if let medium = sizes.medium {
              let w = Float(medium.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "medium"
                ratio = r
              }
            }
            if let small = sizes.small {
              let w = Float(small.w)
              let r = w < width ? width / w : w / width
              if r > 1.0 && r < ratio {
                 size = "small"
                ratio = r
              }
            }
          }
          url = url + ":" + size
          self.fetchImage(with: url, quoted: quoted)
          self.mediaArray.append(media)
          self.playbackButton.isHidden = type == "photo"
          break
        }
      }
    }
  }

  func fetchImage(with urlString: String, quoted: Bool = false) {
    let kCacheTime : TimeInterval = 10 * 60 // [seconds]

    if let iconUrl = URL(string: urlString) {
      let req = URLRequest(url: iconUrl,
                           cachePolicy: .returnCacheDataElseLoad,
                           timeoutInterval: kCacheTime)
      let config = URLSessionConfiguration.default
      let session = URLSession(configuration: config)
      let task = session.dataTask(with: req, completionHandler: {
        [weak self] (data, response, error) in
        if error == nil {
          if let weakSelf = self, let imageData = data, let image = UIImage(data: imageData) {
            DispatchQueue.main.async {
              let w = image.size.width
              let h = image.size.height
              if quoted {
                weakSelf.quotedMedia.contentMode = w < h ? .center : .scaleAspectFit
                weakSelf.quotedMedia.setImage(image, withAnimation: .curveLinear)
              }
              else {
                weakSelf.mediaView.contentMode = w < h ? .center : .scaleAspectFit
                weakSelf.mediaView.setImage(image)
              }
              weakSelf.contentView.setNeedsDisplay()
            }
          }
          else {
            // XXX: Nothing to do now...
          }
        }
        else {
          dump(error)
        }
        session.finishTasksAndInvalidate()
      })
      self.dataTask = task
      task.resume()
    }
  }
}

// MARK: - Icon
extension TDKTweetTableCell
{
  func playbackIcon() -> UIImage? {
    let  width: CGFloat = 56.0
    let height: CGFloat = 56.0
    let   size: CGSize  = CGSize(width: width, height: height)
    let opaque: Bool    = false
    let  scale: CGFloat = 0.0

    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var w: CGFloat = width
    var h: CGFloat = height

    UIGraphicsBeginImageContextWithOptions(size, opaque, scale)

#if     PREFERER_TWITTER_PLAYBACK_BUTTON_DESIGN
    var path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: w, height: h))
    UIColor.white.setFill()
    path.fill()

    x = 4.0
    y = x
    w = width - x * 2.0
    h = w
    path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: w, height: h))
    UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0).setFill()
    path.fill()

    x = 16.0
    y = 16.0
    w = width - x * 2.0
    h = w
    path = UIBezierPath()
    path.move(to: CGPoint(x: x + 4.0, y: y))
    x += w
    y += (h * 0.5)
    path.addLine(to: CGPoint(x: x, y: y))
    x = 20.0
    y += (h * 0.5)
    path.addLine(to: CGPoint(x: x, y: y))
    path.close()
    UIColor.white.setFill()
    path.fill()
#else
    var path = UIBezierPath(ovalIn: CGRect(x: x, y: y, width: w, height: h))
    UIColor(white: 0.0, alpha: 0.3).setFill()
    path.fill()

    x = 14.0
    y = 14.0
    w = width - x * 2.0
    h = w
    path = UIBezierPath()
    path.move(to: CGPoint(x: x + 4.0, y: y))
    x += w
    y += (h * 0.5)
    path.addLine(to: CGPoint(x: x, y: y))
    x = 18.0
    y += (h * 0.5)
    path.addLine(to: CGPoint(x: x, y: y))
    path.close()
    UIColor.white.setFill()
    path.fill()
#endif     // PREFERER_TWITTER_PLAYBACK_BUTTON_DESIGN

    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return image?.withRenderingMode(.alwaysOriginal)
  }

  func playbackHandler(sender: UIButton) {
    if var status = self.tweet {
      if let retweetedStatus = status.retweetedStatus {
        status = retweetedStatus
      }
      if let delegate = self.delegate, let tweet = self.tweet,
         let media = getMedia(of: status)?.first {
        let action = TDKClickableActionType.video(media)
        delegate.clickableAction(action, in: tweet)
      }
      else {
        dump(getMedia(of: status))
      }
    }
  }
}

/*
 * ios - Find out if Character in String is emoji? - Stack Overflow
 * https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
 */
fileprivate extension String {
  var glyphCount: Int {
    let richText = NSAttributedString(string: self)
    let line = CTLineCreateWithAttributedString(richText)
    return CTLineGetGlyphCount(line)
  }

  func containsEmoji() -> Bool {
    for scalar in unicodeScalars {
      switch scalar.value {
        case 0x3030, 0x00AE, 0x00A9,// Special Characters
             0x1D000...0x1F77F,     // Emoticons
              0x2100...0x27BF,      // Misc symbols and Dingbats
              0xFE00...0xFE0F,      // Variation Selectors
             0x1F900...0x1F9FF:     // Supplemental Symbols and Pictographs
          return true
        default:
          continue
      }
    }
    return false
  }
}

fileprivate extension UIImageView
{
  func setImage(_ image: UIImage, withAnimation options: UIViewAnimationOptions = .curveEaseInOut) {
    DispatchQueue.main.async { [weak self] in
      if let weakSelf = self {
        weakSelf.alpha = 0.0
        let animationsClosure = { () -> Void in
          weakSelf.image = image
          weakSelf.alpha = 0.9
        }
        let completionClosure = { (finished: Bool) -> Void in
          weakSelf.alpha = 1.0
        }
        UIView.animate(withDuration: 1.0,
                       delay: 0.4,
                       options: options,
                       animations: animationsClosure,
                       completion: completionClosure)
      }
    }
  }
}
