/*****************************************************************************
 *
 * FILE:	ImageViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: View Controller to Present UIImage
 * DATE:	Fri, Jun 23 2017
 * UPDATED:	Sat, Jun 24 2017
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

class ImageViewController: UIViewController
{
  var scrollView: UIScrollView = UIScrollView()
  var imageView: UIImageView = UIImageView()

  var image: UIImage? = nil

  public convenience init(with image: UIImage) {
    self.init()

    self.image = image
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func loadView() {
    super.loadView()

    self.extendedLayoutIncludesOpaqueBars = true
    self.automaticallyAdjustsScrollViewInsets = false
    self.view.autoresizesSubviews = true
    self.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin ]

    scrollView.frame = self.view.bounds
    scrollView.delegate = self
    scrollView.bounces = false
    scrollView.clipsToBounds = true
    scrollView.scrollsToTop = false
    scrollView.minimumZoomScale = 0.5
    scrollView.maximumZoomScale = 8.0
    scrollView.autoresizesSubviews = true
    scrollView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    scrollView.addSubview(imageView)
    imageView.isUserInteractionEnabled = true
    imageView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    self.view.addSubview(scrollView)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    if let image = self.image {
      imageView.image = image
    }

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    imageView.addGestureRecognizer(tapGesture)

    let closeItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                    target: self,
                                    action: #selector(closeAction))
    self.navigationItem.leftBarButtonItem = closeItem
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.navigationBar.isHidden = false
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let size = self.image?.size {
      let  scrollWidth: CGFloat = scrollView.frame.size.width
      let scrollHeight: CGFloat = scrollView.frame.size.height
      let   imageWidth: CGFloat = size.width
      let  imageHeight: CGFloat = size.height
      let  widthFactor: CGFloat =  scrollWidth / imageWidth
      let heightFactor: CGFloat = scrollHeight / imageHeight
      let  scaleFactor: CGFloat = min(widthFactor, heightFactor, 1.0)
      let  scaledWidth: CGFloat = floor( imageWidth * scaleFactor)
      let scaledHeight: CGFloat = floor(imageHeight * scaleFactor)

      let imageSize = CGSize(width: scaledWidth, height: scaledHeight)
      imageView.frame.size = imageSize
      scrollView.contentSize = imageSize

      updateScrollInset()
    }
  }

  // http://qiita.com/wmoai/items/52b1901e62d28dae9f91
  func updateScrollInset() {
    var offset: CGFloat = 0.0

    if let navigationController = self.navigationController {
      if !navigationController.navigationBar.isHidden {
        offset = navigationController.navigationBar.frame.size.height
      }
      else {
        offset = 0.0
      }
    }

    // imageView の大きさから contentInset を再計算
    // なお、0を下回らないようにする
    let  width = scrollView.frame.width  - imageView.frame.width
    let height = scrollView.frame.height - imageView.frame.height
    scrollView.contentInset = UIEdgeInsets(
         top: max((height * 0.5), offset),
        left: max((width * 0.5), 0.0),
      bottom: 0.0,
       right: 0.0
    )
  }
}

extension ImageViewController
{
  func closeAction(sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }

  func tapHandler(gesture: UITapGestureRecognizer) {
    if let isHidden = self.navigationController?.navigationBar.isHidden {
      self.navigationController?.setNavigationBarHidden(!isHidden, animated: true)
    }
  }
}

extension ImageViewController: UIScrollViewDelegate
{
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    // ズームのために要指定
    return imageView
  }

  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    // ズームのタイミングでcontentInsetを更新
    updateScrollInset()
  }
}
