//
//  AblumList.swift
//  PH
//
//  Created by qmc on 16/11/2.
//  Copyright © 2016年 刘俊杰. All rights reserved.
//

import UIKit
import Photos

class AblumList: NSObject {
    var title: String!                      //相册名字
    var count: Int!                         //该相册内相片数量
    var headImageAsset: PHAsset!            //相册第一张图片缩略图
    var assetCollection: PHAssetCollection! //相册集，通过该属性获取该相册集下所有照片
}

private let _sharePhotoTool = AblumTool()

class AblumTool: NSObject {
    
     //MARK: 获取用户所有相册列表
    /**
     获取用户所有相册列表
     
     - returns: 用户相册
     */
    
    class func sharePhotoTool()->AblumTool {
        return _sharePhotoTool
    }
    
    private override init() {
        super.init()
    }
    
    func getPhotoAblumList()->[AblumList]{
        
        var photoAblumList = [AblumList]()
        // 获取所有智能相册
        let smartAblums: PHFetchResult = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .AlbumRegular, options: nil)
        smartAblums.enumerateObjectsUsingBlock { (collection , idx, stop) in
            //过滤掉视频和最近删除
            let coll = collection as! PHAssetCollection
//            print("localizedTitle:\(coll.localizedTitle)")
            
            if !(coll.localizedTitle == "Recently Deleted" || coll.localizedTitle! == "Videos") {
                let assets = self.getAssetsInAssetCollection(coll, ascending: false)
//                print("count:\(assets.count)")
                if assets.count > 0 {
                    let ablum = AblumList()
                    ablum.title = self.transformAblumTitle(coll.localizedTitle!)
//                    print("过滤掉视频和最近删除localizedTitle:\(ablum.title)")
                    ablum.count = assets.count
                    ablum.headImageAsset = assets.first
                    ablum.assetCollection = coll
                    photoAblumList.append(ablum)
                }
            }
        }
        
        //获取用户创建的相册
        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .SmartAlbumUserLibrary, options: nil)
        userAlbums.enumerateObjectsUsingBlock { (coll, idx, stop) in
            let collection = coll as! PHAssetCollection
            let assets = self.getAssetsInAssetCollection(collection, ascending: false)
            if assets.count > 0 {
                let ablum = AblumList()
                ablum.title = collection.localizedTitle
//                print("获取用户创建的相册localizedTitle:\(collection.localizedTitle)")
                ablum.count = assets.count
                ablum.headImageAsset = assets.first
                ablum.assetCollection = collection
                photoAblumList.append(ablum)
            }
        }
        
        return photoAblumList
    }
    
    //MARK: 获取相册内所有图片资源
    /**
     获取相册内所有图片资源
     
     - parameter ascending: 是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
     
     - returns: 所有图片资源
     */
    func getAllAssetInphotoAblumWithAscending(ascending: Bool) ->[PHAsset] {
        var assets = [PHAsset]()
        let option = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: ascending)
        option.sortDescriptors = [sort]
        let result = PHAsset.fetchAssetsWithMediaType(.Image, options: option)
        result.enumerateObjectsUsingBlock { (obj, idx, stop) in
            let asset = obj as! PHAsset
            assets.append(asset)
        }
        
        return assets
    }
    
    //MARK: 获取指定相册内所有图片资源
    /**
      获取相册内所有图片资源
     
     - parameter ascending:       是否按创建时间正序排列 YES,创建时间正（升）序排列; NO,创建时间倒（降）序排列
     
     - returns: 图片资源
     */
    func getAssetsInAssetCollection(assetCollection: PHAssetCollection, ascending: Bool) ->[PHAsset]{
        var arr = [PHAsset]()
        let result: PHFetchResult = self.fetchAssetsInAssetCollection(assetCollection, ascending: ascending)
        result.enumerateObjectsUsingBlock { (obj, idx, stop) in
            let asset = obj as! PHAsset
            if asset.mediaType == .Image {
                arr.append(asset)
            }
        }
       return arr
    }
    //MARK: 获取每个Asset对应的图片
    /**
     获取每个Asset对应的图片
     
     - parameter asset:      图片资源
     - parameter size:       大小
     - parameter resizeMode: how to resize the requested image to fit a target size
     - parameter competion:  imageBlock
     */
    func requestImageForAsset(asset: PHAsset, size: CGSize, resizeMode: PHImageRequestOptionsResizeMode, competion: (image: UIImage)-> Void) {
        /**
         
         resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
         
         deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
         
         这个属性只有在 synchronous 为 true 时有效。
         
         */
        let option = PHImageRequestOptions()
        option.resizeMode = resizeMode //控制照片尺寸
        //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic//控制照片质量
        //option.synchronous = YES
        
        option.networkAccessAllowed = true
        //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
        
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFit, options: option) { (image, info) in
            competion(image: image!)
        }
    }
    
    
    func fetchAssetsInAssetCollection(assetCollection: PHAssetCollection, ascending: Bool) -> PHFetchResult {
        let option = PHFetchOptions()
        let sort = NSSortDescriptor(key: "creationDate", ascending: ascending)
        option.sortDescriptors = [sort]
        let result = PHAsset.fetchAssetsInAssetCollection(assetCollection, options: option)
        return result
    }
    
    //MARK: private Method 
    
    func transformAblumTitle(title: String) ->String {
        
        /*
         localizedTitle:Optional("Favorites") 最爱
         localizedTitle:Optional("Recently Deleted") 最近删除
         localizedTitle:Optional("Panoramas") 全景照片
         localizedTitle:Optional("Camera Roll") 相机胶卷
         localizedTitle:Optional("Slo-mo") 慢动作
         localizedTitle:Optional("Screenshots") 屏幕快照
         localizedTitle:Optional("Bursts")
         localizedTitle:Optional("Videos") 视频
         localizedTitle:Optional("Selfies") 自拍
         localizedTitle:Optional("Hidden")  隐藏
         localizedTitle:Optional("Time-lapse") Time-lapse
         localizedTitle:Optional("Recently Added")
         
         
         */
//        print("transformAblumTitle: \(title)")
        switch title {
        case "Slo-mo":
            return "慢动作"
        case "Recently Added":
            return "最近添加"
        case "Favorites":
            return "最爱"
        case "Recently Deleted":
            return "最近删除"
        case "Videos":
            return "视频"
        case "All Photos":
            return "所有照片"
        case "Selfies":
            return "自拍"
        case "Screenshots":
            return "屏幕快照"
        case "Camera Roll":
            return "相机胶卷"
        case "Panoramas":
            return "全景照片"
        default:
            return title
        }
    }
    
}