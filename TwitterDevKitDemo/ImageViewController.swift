/*****************************************************************************
 *
 * FILE:	ImageViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: View Controller to Present UIImage
 * DATE:	Fri, Jun 23 2017
 * UPDATED:	Wed, Sep 13 2017
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

  var isSizeFit: Bool = false

  public convenience init(with image: UIImage) {
    self.init()

    self.image = image

    self.title = String(format: "%.0fx%.0f", image.size.width, image.size.height)
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

    let closeItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                    target: self,
                                    action: #selector(closeAction))
    closeItem.tintColor = .lightGray
    self.navigationItem.leftBarButtonItem = closeItem

    let actionItem = UIBarButtonItem(barButtonSystemItem: .action,
                                     target: self,
                                     action: #selector(handleAction))
    self.navigationItem.rightBarButtonItem = actionItem

    self.addGestures()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear

    UIApplication.shared.isStatusBarHidden = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    self.navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.navigationController?.navigationBar.isHidden = false

    UIApplication.shared.isStatusBarHidden = false
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    imageSizeToFit(true, animated: false)
  }
}

// MARK: - Handle UIBarButtonItem Action on UINavigationBar
extension ImageViewController
{
  func closeAction(sender: UIBarButtonItem) {
    self.dismiss(animated: true, completion: nil)
  }

  func handleAction(_ sender: UIBarButtonItem) {
    autoreleasepool {
      if let image = self.image {
        let items = [image]
        let viewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(viewController, animated: true, completion: nil)
      }
    }
  }
}

extension ImageViewController
{
  func imageSizeToFit(_ fit: Bool, animated: Bool = true) {
    if let imageSize = image?.size {
      let  imageWidth: CGFloat = imageSize.width
      let imageHeight: CGFloat = imageSize.height
      let    viewSize: CGSize  = self.view.bounds.size
      let   viewWidth: CGFloat = viewSize.width
      let  viewHeight: CGFloat = viewSize.height
      var centerPoint: CGPoint = .zero
      var  scaledSize: CGSize  = imageSize

      if fit {
        let  widthFactor: CGFloat =  viewWidth / imageWidth
        let heightFactor: CGFloat = viewHeight / imageHeight
        let  scaleFactor: CGFloat = min(widthFactor, heightFactor, 1.0)
        let  scaledWidth: CGFloat = floor( imageWidth * scaleFactor)
        let scaledHeight: CGFloat = floor(imageHeight * scaleFactor)

        scaledSize = CGSize(width: scaledWidth, height: scaledHeight)

        if (widthFactor < heightFactor) {
          centerPoint.y = floor((viewHeight - scaledHeight) * 0.5)
        }
        else if (widthFactor > heightFactor) {
          centerPoint.x = floor((viewWidth - scaledWidth) * 0.5)
        }
        scrollView.contentSize = CGSize(width: viewWidth, height: viewHeight)
      }
      else {
        if (imageWidth < viewWidth) {
          centerPoint.x = floor((viewWidth - imageWidth) * 0.5)
        }
        if (imageHeight < viewHeight) {
          centerPoint.y = floor((viewHeight - imageHeight) * 0.5)
        }
        scrollView.contentSize = CGSize(width: imageWidth, height: imageHeight)
      }

      imageView.frame = CGRect(origin: centerPoint, size: scaledSize)
      if animated {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.1
        scaleAnimation.toValue = 1.0
        scaleAnimation.duration = 0.8
        scaleAnimation.autoreverses = false
        scaleAnimation.isRemovedOnCompletion = true
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        imageView.layer.add(scaleAnimation, forKey: "scaleAnimation")
      }

      isSizeFit = fit
    }
  }

  func zoomRect(for scale: CGFloat, with center: CGPoint) -> CGRect {
    var zoomRect: CGRect = .zero

    /*
     * The zoom rect is in the content view's coordinates.
     * At a zoom scale of 1.0, it would be the size of the scrollView's bounds.
     * As the zoom scale decreases, so more content is visible, the size fo
     * the rect grows.
     */
    let scrollViewSize = scrollView.frame.size
    zoomRect.size.width  = floor(scrollViewSize.width  / scale)
    zoomRect.size.height = floor(scrollViewSize.height / scale)

    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  * 0.5)
    zoomRect.origin.y = center.y - (zoomRect.size.height * 0.5)

    return zoomRect
  }
}

extension ImageViewController: UIScrollViewDelegate
{
  // return a view that will be scaled. if delegate returns nil, nothing happens
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }

  // any zoom scale changes
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    let   boundsWidth = scrollView.bounds.size.width
    let  boundsHeight = scrollView.bounds.size.height
    let  contentWidth = scrollView.contentSize.width
    let contentHeight = scrollView.contentSize.height

    let offsetX: CGFloat = boundsWidth > contentWidth
                         ? floor((boundsWidth - contentWidth) * 0.5)
                         : 0.0
    let offsetY: CGFloat = boundsHeight > contentHeight
                         ? floor((boundsHeight - contentHeight) * 0.5)
                         : 0.0
    var centerPoint: CGPoint = .zero

    centerPoint.x =  contentWidth * 0.5 + offsetX
    centerPoint.y = contentHeight * 0.5 + offsetY
    imageView.center = centerPoint
  }
}

extension ImageViewController
{
  func addGestures() {
    let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
    singleTap.numberOfTapsRequired = 1
    imageView.addGestureRecognizer(singleTap)

    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
    doubleTap.numberOfTapsRequired = 2
    imageView.addGestureRecognizer(doubleTap)

    singleTap.require(toFail: doubleTap)

    let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(holdHandler))
    holdGesture.minimumPressDuration = 1.8 // seconds
    imageView.addGestureRecognizer(holdGesture)
  }

  func tapHandler(gesture: UITapGestureRecognizer) {
    if let isHidden = self.navigationController?.navigationBar.isHidden {
      self.navigationController?.setNavigationBarHidden(!isHidden, animated: true)
    }
  }

  func doubleTapHandler(gesture: UITapGestureRecognizer) {
    if let imageSize = image?.size {
      let  imageWidth: CGFloat = imageSize.width
      let imageHeight: CGFloat = imageSize.height
      let    viewSize: CGSize  = self.view.bounds.size
      let   viewWidth: CGFloat = viewSize.width
      let  viewHeight: CGFloat = viewSize.height
      var scaleFactor: CGFloat = 1.0

      if isSizeFit {
        let  widthFactor: CGFloat =  imageWidth / viewWidth
        let heightFactor: CGFloat = imageHeight / viewHeight
        scaleFactor = max(widthFactor, heightFactor, 1.0)
      }
      isSizeFit = !isSizeFit

      let point = gesture.location(in: gesture.view)
      let rect = zoomRect(for: scaleFactor, with: point)
      scrollView.zoom(to: rect, animated: true)
    }
  }

  func holdHandler(gesture: UILongPressGestureRecognizer) {
    guard gesture.state == .began else { return } // 押し始めのみ利用

    if let image = self.image {
      UIImageWriteToSavedPhotosAlbum(image, self, #selector(handleSavedImage(_:didFinishSavingWithError:contextInfo:)), nil) 
    }
  }

  func handleSavedImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeMutableRawPointer) {
    let title: String
    let message: String
    if let error = error {
      title = "Error"
      message = error.localizedDescription
    }
    else {
      title = "Completed"
      message = "Saved the image into Photo Album."
    }
    DispatchQueue.main.async() { [weak self] () -> Void in
      if let weakSelf = self {
        autoreleasepool {
          let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
          weakSelf.present(alertController, animated: true, completion: nil)
        }
      }
    }
  }
}
