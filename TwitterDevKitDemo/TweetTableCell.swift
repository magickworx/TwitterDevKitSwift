/*****************************************************************************
 *
 * FILE:	TweetTableCell.swift
 * DESCRIPTION:	TwitterDevKitDemo: Custom TDKTweetTableCell Class
 * DATE:	Tue, Sep  5 2017
 * UPDATED:	Tue, Nov  7 2017
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
 * $Id: AppDelegate.m,v 1.6 2017/04/12 09:59:00 kouichi Exp $
 *
 *****************************************************************************/

import Foundation
import UIKit
import QuartzCore
import TwitterDevKitSwift

enum TweetAction
{
  case none
  case chat
  case retweet
  case favorite
  case mail
  case json
}

typealias TweetActionFinishHandler = (Bool) -> Void

protocol TweetTableCellDelegate: TDKClickableActionDelegate
{
  func tweetAction(_ action: TweetAction, for tweet: TDKTweet, finished: @escaping TweetActionFinishHandler)
}

class TweetTableCell: TDKTweetTableCell
{
  /*
   * ios - Overriding delegate property of UIScrollView in Swift (like
   *       UICollectionView does) - Stack Overflow
   * https://stackoverflow.com/questions/25724709/overriding-delegate-property-of-uiscrollview-in-swift-like-uicollectionview-doe
   */
  weak var myDelegate: TweetTableCellDelegate?
  override weak var delegate: TDKClickableActionDelegate? {
    didSet {
      myDelegate = delegate as? TweetTableCellDelegate
    }
  }

  let toolbox: UIView = UIView()
  let toolboxHeight: CGFloat = 32.0

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    toolbox.backgroundColor = .clear
    self.contentView.addSubview(toolbox)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()

    let  width = self.contentView.bounds.size.width
    let height = self.contentView.bounds.size.height
    let x: CGFloat = 0.0
    let y: CGFloat = height - toolboxHeight
    let w: CGFloat = width
    let h: CGFloat = toolboxHeight
    toolbox.frame = CGRect(x: x, y: y, width: w, height: h)
    makeToolbox()
  }

  open override func prepareForReuse() {
    super.prepareForReuse()
  }

  open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
    let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    return CGSize(width: size.width, height: size.height + toolboxHeight)
  }
}

extension TweetTableCell
{
  class TweetActionButton: UIButton
  {
    var action: TweetAction = .none
  }

  func makeToolbox() {
    let leftMargin: CGFloat = 48.0 + 8.0 * 2.0
    let width: CGFloat = self.contentView.bounds.size.width - leftMargin
    let iconSize: CGFloat = 30.0 // XXX: 実際には UIButton のサイズ
    let space: CGFloat = floor((width - iconSize * 5.0) / 5.0)

    var x: CGFloat = leftMargin
    let y: CGFloat = (toolboxHeight - iconSize) * 0.5
    let w: CGFloat = iconSize
    let h: CGFloat = w
    let m: CGFloat = w + space

    let makeButton = { [unowned self] (_ image: UIImage, _ frame: CGRect, _ action: TweetAction) in
      let button = TweetActionButton(type: .custom)
      self.toolbox.addSubview(button)
      button.addTarget(self, action: #selector(self.buttonAnimation), for: .touchDown)
      button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
      button.action = action
      button.frame = frame
      button.setImage(image, for: .normal)
      button.tintColor = .lightGray
    }

    let actions: [TweetAction] = [
      .chat, .retweet, .favorite, .mail, .json
    ]
    for action in actions {
      /*
       * swift - Change color of png in buttons - ios - Stack Overflow
       * https://stackoverflow.com/questions/27163171/change-color-of-png-in-buttons-ios
       */
      if let image = action.image()?.withRenderingMode(.alwaysTemplate) {
        makeButton(image, CGRect(x: x, y: y, width: w, height: h), action)
        x += m
      }
    }
  }

  @objc func buttonAction(_ button: TweetActionButton) {
    if let delegate = self.myDelegate, let tweet = self.tweet {
      delegate.tweetAction(button.action, for: tweet, finished: {
        [unowned self] (_ finished: Bool) in
        if finished {
          DispatchQueue.main.async {
            self.buttonColor(button, tapped: false)
          }
        }
      })
    }
  }

  func buttonColor(_ button: TweetActionButton, tapped: Bool) {
      switch button.action {
        case .chat:
          button.tintColor = tapped ? .green : .lightGray
        case .retweet:
          button.tintColor = tapped ? .blue : .lightGray
        case .favorite:
          button.tintColor = tapped ? .red : .lightGray
        case .mail:
          button.tintColor = tapped ? .orange : .lightGray
        default:
          button.tintColor = .darkGray
      }
  }

  @objc func buttonAnimation(_ button: TweetActionButton) {
    guard button.action != .json else { return }
    DispatchQueue.main.async { [unowned self] in
      self.animateButton(button)
      self.buttonColor(button, tapped: true)
    }
  }

  func animateButton(_ button: TweetActionButton) {
    let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
    scaleAnimation.fromValue = 1.0
    scaleAnimation.toValue = 2.0
    scaleAnimation.duration = 0.5
    scaleAnimation.autoreverses = true
    scaleAnimation.isRemovedOnCompletion = true
    scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    button.layer.add(scaleAnimation, forKey: "scaleAnimation")
  }
}


extension TweetAction
{
  func image() -> UIImage? {
    switch self {
      case .none:
        return nil
      case .chat:
        return UIImage(named: "icon_chat")
      case .retweet:
        return UIImage(named: "icon_retweet")
      case .favorite:
        return UIImage(named: "icon_favorite")
      case .mail:
        return UIImage(named: "icon_mail")
      case .json:
        return UIImage(named: "icon_more")
    }
  }
}
