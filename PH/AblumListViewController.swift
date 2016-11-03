//
//  AblumListViewController.swift
//  PH
//
//  Created by qmc on 16/11/2.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

import UIKit

let AblumlistCellId = "AblumListCellId"

class AblumListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
     let ablumTool = AblumTool.sharePhotoTool()
    var dataArray = [AblumList]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "相册"
        self.dataArray = ablumTool.getPhotoAblumList()
        
        let w = WiFi().getMac()
        print("NetworkInfo:\(w)")
        print("WiFi\(WiFi().reachable)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

private typealias delegateExtension = AblumListViewController

extension delegateExtension {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AblumlistCellId, forIndexPath: indexPath) as! AblumListTableViewCell
        let ablum = self.dataArray[indexPath.row]
        
        ablumTool.requestImageForAsset(ablum.headImageAsset, size: CGSizeMake(64, 64), resizeMode: .Fast, competion: { (image) in
            cell.imageV.image = image
        })
        cell.label.text = "\(ablum.title)  \(ablum.count)"
        return cell
    }
    
}