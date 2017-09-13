/*****************************************************************************
 *
 * FILE:	DumpViewController.swift
 * DESCRIPTION:	TwitterDevKitDemo: View Controller to Print String from dump()
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

import UIKit
import TwitterDevKit

class DumpViewController: BaseViewController
{
  var textView: UITextView = UITextView()
  var text: String? = nil

  public convenience init(with text: String) {
    self.init()

    self.title = "JSON Entity"
    self.text = text
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func loadView() {
    super.loadView()

    let  width: CGFloat = self.view.bounds.size.width
    let height: CGFloat = self.view.bounds.size.height
    let x: CGFloat = 0.0
    let y: CGFloat = 0.0
    let w: CGFloat = width
    let h: CGFloat = height

    textView.frame = CGRect(x: x, y: y, width: w, height: h)
    textView.font = UIFont.systemFont(ofSize: 10.0)
    textView.isEditable = false
    self.view.addSubview(textView)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let actionItem = UIBarButtonItem(barButtonSystemItem: .action,
                                     target: self,
                                     action: #selector(handleAction))
    self.navigationItem.rightBarButtonItem = actionItem
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.navigationBar.isHidden = false

    if let text = self.text {
      self.textView.text = text
    }
  }
}

extension DumpViewController
{
  func handleAction(_ sender: UIBarButtonItem) {
    autoreleasepool {
      if let text = self.text {
        let items = [text]
        let viewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(viewController, animated: true, completion: nil)
      }
    }
  }
}
