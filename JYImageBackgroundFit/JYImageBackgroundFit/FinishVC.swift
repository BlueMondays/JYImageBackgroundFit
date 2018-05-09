//
//  FinishVC.swift
//  JYImageBackgroundFit
//
//  Created by 박지연 on 2018. 5. 9..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit

class FinishVC: UIViewController {

	@IBOutlet private var ivSaveImage: UIImageView!
	var image: UIImage!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		initUI()
    }

	private func initUI() {
		ivSaveImage.layer.borderColor = UIColor.gray.cgColor
		ivSaveImage.layer.borderWidth = 2
		
		ivSaveImage.image = image
	}
	
	@IBAction func userWillKeepEdit(_ sender: UIButton) {
		self.navigationController?.popViewController(animated: true)
	}
	
	@IBAction func userDidWillFinishEdit(_ sender: UIButton) {
		self.navigationController?.popToRootViewController(animated: true)
	}
	
}
