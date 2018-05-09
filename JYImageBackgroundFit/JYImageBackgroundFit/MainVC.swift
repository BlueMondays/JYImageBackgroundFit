//
//  MainVC.swift
//  JYImageBackgroundFit
//
//  Created by 박지연 on 2018. 5. 8..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos

extension PHAsset {
	func toImage() -> UIImage {
		var thumbnail = UIImage()
		
		let manager = PHImageManager.default()
		let options = PHImageRequestOptions()
		options.resizeMode = .exact
		options.deliveryMode = .highQualityFormat
		options.isSynchronous = true
		
		manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options, resultHandler: {(result, info)->Void in
			thumbnail = result!
		})
		return thumbnail
	}
}

class MainVC: UIViewController {
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction private func onBtnGalleryDidTouchUpInside(_ sender: UIButton) {
		
		let picker = BSImagePickerViewController()
		bs_presentImagePickerController(picker,
										animated: true,
										select: { asset in
		},
										deselect: { asset in
		},
										cancel: { asset in
											
		},
										finish: { asset in
											let images = asset.map({ $0.toImage() })
											let editVC = EditVC(nibName: "EditVC", bundle: Bundle.main)
											editVC.images = images
											self.navigationController?.pushViewController(editVC, animated: true)
		},
										completion: {
										
		})
	}
}
