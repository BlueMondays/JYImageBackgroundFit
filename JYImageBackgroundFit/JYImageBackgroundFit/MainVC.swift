//
//  MainVC.swift
//  JYImageBackgroundFit
//
//  Created by 박지연 on 2018. 5. 8..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction private func onBtnGalleryDidTouchUpInside(_ sender: UIButton) {
		let picker = UIImagePickerController()
		picker.delegate = self
		picker.allowsEditing = false
		picker.sourceType = .photoLibrary
		
		self.present(picker, animated: true, completion: nil)//navigationController?.pushViewController(picker, animated: true)
	}
	
	func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
		self.dismiss(animated: true, completion: { () -> Void in
			let editVC = EditVC(nibName: "EditVC", bundle: Bundle.main)
			editVC.images = [image]
		})
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		guard let pickerImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			print("image no : \(info)")
			return
		}
		
		picker.dismiss(animated: true, completion: { () -> Void in
			let editVC = EditVC(nibName: "EditVC", bundle: Bundle.main)
			editVC.images = [pickerImage]
			self.navigationController?.pushViewController(editVC, animated: true)
		})
		
	}

}
