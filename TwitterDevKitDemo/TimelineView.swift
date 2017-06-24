/*****************************************************************************
 *
 * FILE:	TimelineView.swift
 * DESCRIPTION:	TwitterDevKitDemo: Generic Timeline View Class
 * DATE:	Sat, Jun 10 2017
 * UPDATED:	Fri, Jun 23 2017
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

protocol TimelineViewDelegate: TDKClickableActionDelegate
{
  func timelineView(_ timelineView: TimelineView, willRefreshSince latestTweet: TDKTweet) -> Void

  func timelineView(_ timelineView: TimelineView, didSelect tweet: TDKTweet) -> Void
}

let kTableCellIdentifier = "Tweet"

class TimelineView: UIView
{
  public var delegate: TimelineViewDelegate? = nil

  var tableView: UITableView = UITableView()
  var tableData: [AnyObject] = []

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .white
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 388
    tableView.allowsSelection = true
    tableView.separatorInset = UIEdgeInsets.zero
    tableView.layoutMargins = UIEdgeInsets.zero
    tableView.register(TDKTweetTableCell.self, forCellReuseIdentifier: kTableCellIdentifier)
    self.addSubview(tableView)

    let refreshControl: UIRefreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    tableView.refreshControl = refreshControl
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let  width: CGFloat = self.bounds.size.width
    let height: CGFloat = self.bounds.size.height
    let x: CGFloat = 0.0
    let y: CGFloat = 0.0
    let w: CGFloat = width
    let h: CGFloat = height

    tableView.frame = CGRect(x: x, y: y, width: w, height: h)
  }

  func refreshTableView() {
    if let tweet: TDKTweet = tableData.first as? TDKTweet {
      delegate?.timelineView(self, willRefreshSince: tweet)
    }
  }
}

extension TimelineView
{
  public func setTimelineData(_ data: [AnyObject]) {
    DispatchQueue.main.async() {
      if let refreshControl = self.tableView.refreshControl {
        if refreshControl.isRefreshing {
          refreshControl.endRefreshing()
        }
      }
      var tempData = data
      tempData.append(contentsOf: self.tableData)
      self.tableData = tempData
      self.tableView.reloadData()
    }
  }
}

/*
 * MARK: - UITableViewDataSource
 */
extension TimelineView: UITableViewDataSource
{
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    let tweet = self.tableData[row] as! TDKTweet
    let cell: TDKTweetTableCell = tableView.dequeueReusableCell(withIdentifier: kTableCellIdentifier, for: indexPath) as! TDKTweetTableCell
    cell.tweet = tweet
    if let delegate = self.delegate {
      cell.delegate = delegate
    }
    return cell
  }
}

/*
 * MARK: - UITableViewDelegate
 */
extension TimelineView: UITableViewDelegate
{
/*
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }

  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
*/

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let row = indexPath.row
    if let tweet = self.tableData[row] as? TDKTweet {
      delegate?.timelineView(self, didSelect: tweet)
    }
  }
}
