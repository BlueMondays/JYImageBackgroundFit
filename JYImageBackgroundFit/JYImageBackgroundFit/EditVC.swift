//
//  EditVC.swift
//  JYImageBackgroundFit
//
//  Created by 박지연 on 2018. 5. 8..
//  Copyright © 2018년 박지연. All rights reserved.
//

import UIKit

enum photoAlign: String {
	case middle = "middle"
	case xmiddle = "xmiddle"
	case ymiddle = "ymiddle"
	case top = "top"
	case bottom = "bottom"
	case left = "left"
	case right = "right"
}

enum backgroundColor {
	case black
	case white
	case pink
	case lightpink
	case lightpurple
	case lightgray
	case none
}

extension UIColor {
	func hexColor(_ hex: String) -> UIColor {
		var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		
		if (cString.hasPrefix("#")) {
			cString.remove(at: cString.startIndex)
		}
		
		if ((cString.count) != 6) {
			return UIColor.gray
		}
		
		var rgbValue:UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

extension UIImage {
	convenience init(view: UIView) {
		UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0)
		view.layer.render(in:UIGraphicsGetCurrentContext()!)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		self.init(cgImage: image!.cgImage!)
	}
}


class EditVC: UIViewController {

	private let alignTitle: [photoAlign] = [.middle, .xmiddle, .ymiddle, .top, .bottom, .left, .right]
	private let colorTitle: [backgroundColor] = [.black, .white, .pink, .lightpink, .lightpurple, .lightgray, .none]
	
	@IBOutlet private var vContainer: UIView!
	@IBOutlet private var vNavigationBar: UIView!
	@IBOutlet private var vBottomBar: UIView!
	@IBOutlet private var vBackground: UIView!
	@IBOutlet private var svScrollview: UIScrollView!
	@IBOutlet private var lcsvScrollviewHeight: NSLayoutConstraint!
	
	private var isNavigationHidden = false {
		didSet {
			
			seletedSubMenuIndex = -1
			
			if isNavigationHidden {
				navigationbarWillHidden()
			} else {
				navigationbarWillShow()
			}
		}
	}

	private var selectedIvImage: UIImageView? {
		didSet {
			guard oldValue != selectedIvImage else {
				return
			}
			
			ivs.forEach({ iv in
				iv.layer.borderColor = UIColor.clear.cgColor
				iv.layer.borderWidth = 0
			})
			
			if let iv = selectedIvImage {
				iv.layer.borderColor = UIColor.blue.cgColor
				iv.layer.borderWidth = 2.0
			}
		}
	}
	
	private var seletedPriviousMovePoint: CGPoint?
	private var seletedSubMenuIndex = -1 {
		didSet {
			lcsvScrollviewHeight.constant = seletedSubMenuIndex > 0 ? 60 : 0
			svScrollview.layoutIfNeeded()
		}
	}
	
	private var vAlignOption: UIView!
	private var vColorOption: UIView!
	private var imageLastScale = [UIImageView: CGFloat]()
	private var ivs = [UIImageView]()
	private var isPinching = false
	
	var images = [UIImage]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		viewDidLayoutSubviews()
		initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
	
	private func initUI() {
		// UI를 이니셜라이징
		
		images.forEach({ image in
			var ivSize = image.size
			// 우선적으로 가로사이즈에 맞춥니다.
			
			if image.size.width > vContainer.frame.size.width,
				image.size.height > vContainer.frame.size.height {
				// 가로와 세로 사이즈가 모두 넘친다.
				let aspectWidth = vContainer.frame.size.width / image.size.width
				let aspectHeight = vContainer.frame.size.height / image.size.height
				
				let aspect = aspectHeight < aspectWidth ? aspectHeight : aspectWidth
				ivSize.width = image.size.width * aspect
				ivSize.height = image.size.height * aspect
			} else if image.size.width > vContainer.frame.size.width {
				// 너비가 넘친다
				let aspect = vContainer.frame.size.width / image.size.width
				ivSize.width = image.size.width * aspect
				ivSize.height = image.size.height * aspect
			} else if image.size.height > vContainer.frame.size.height {
				// 높이가 넘친다
				let aspect = vContainer.frame.size.height / image.size.height
				ivSize.width = image.size.height * aspect
				ivSize.height = image.size.height * aspect
			}
			
			var ivOrigin = CGPoint()
			ivOrigin.x = vContainer.frame.midX - ivSize.width/2
			ivOrigin.y = vContainer.frame.midY - ivSize.height/2
			
			
			let iv = UIImageView(frame: CGRect(origin: ivOrigin,
												size: ivSize))
			iv.image = image
			iv.isUserInteractionEnabled = true
			ivs.append(iv)
			
			vContainer.insertSubview(iv, aboveSubview: vBackground)
		})
		
		selectedIvImage = ivs.last
		
		vAlignOption = UIView()
		alignTitle.forEach({
			let button = UIButton(type: .custom)
			button.setImage(UIImage(named: $0.rawValue), for: .normal)
			button.tag = alignTitle.index(of: $0) ?? -1
			button.addTarget(self, action: #selector(onBtnAlignOptionDidTouch), for: .touchUpInside)
			vAlignOption.addSubview(button)
			button.translatesAutoresizingMaskIntoConstraints = false
			
			if $0.hashValue == 0 {
				// 맨 첫번째
				vAlignOption.addConstraint(NSLayoutConstraint(item: button,
														attribute: .leading,
														relatedBy: .equal,
														toItem: vAlignOption,
														attribute: .leading,
														multiplier: 1,
														constant: 0))
			} else if $0.hashValue == (alignTitle.count - 1) {
				// 맨 마지막
				vAlignOption.addConstraint(NSLayoutConstraint(item: button,
														attribute: .trailing,
														relatedBy: .equal,
														toItem: vAlignOption,
														attribute: .trailing,
														multiplier: 1,
														constant: 0))
			}
			
			if let priviousItem = vAlignOption.viewWithTag($0.hashValue - 1) as? UIButton {
				vAlignOption.addConstraint(NSLayoutConstraint(item: button,
														attribute: .leading,
														relatedBy: .equal,
														toItem: priviousItem,
														attribute: .trailing,
														multiplier: 1,
														constant: 0))
			}
			
			button.addConstraint(NSLayoutConstraint(item: button,
													 attribute: .width,
													 relatedBy: .equal,
													 toItem: nil,
													 attribute: .notAnAttribute,
													 multiplier: 1,
													 constant: 60))

			
			vAlignOption.addConstraint(NSLayoutConstraint(item: button,
													attribute: .top,
													relatedBy: .equal,
													toItem: vAlignOption,
													attribute: .top,
													multiplier: 1,
													constant: 0))
			
			vAlignOption.addConstraint(NSLayoutConstraint(item: button,
													attribute: .bottom,
													relatedBy: .equal,
													toItem: vAlignOption,
													attribute: .bottom,
													multiplier: 1,
													constant: 0))
		})
		
		vColorOption = UIView()
		colorTitle.forEach({
			let button = UIButton(type: .custom)

			switch $0 {
			case .black: // 검정
				button.backgroundColor = .black
			case .white: // 흰색
				button.backgroundColor = .white
			case .pink: // 진핑크
				button.backgroundColor = UIColor().hexColor("#eb9f9f")
			case .lightpink: // 연핑크
				button.backgroundColor = UIColor().hexColor("#f1bbba")
			case .lightpurple: // 연보라
				button.backgroundColor = UIColor().hexColor("#D7ACF6")
			case .lightgray: // 밝은회색
				button.backgroundColor = UIColor().hexColor("#B7D7D9")
			default:
				button.layer.borderColor = UIColor.white.cgColor
				button.layer.borderWidth = 2
				button.backgroundColor = .clear
				button.setTitle("기타", for: .normal)
				//기타 colorpicker
			}
			
			button.layer.cornerRadius = 30
			button.tag = $0.hashValue
			button.addTarget(self, action: #selector(onBtnColorOptionDidTouch), for: .touchUpInside)
			vColorOption.addSubview(button)
			button.translatesAutoresizingMaskIntoConstraints = false
			
			if button.tag == 0 {
				// 맨 첫번째
				vColorOption.addConstraint(NSLayoutConstraint(item: button,
															 attribute: .leading,
															 relatedBy: .equal,
															 toItem: vColorOption,
															 attribute: .leading,
															 multiplier: 1,
															 constant: 0))
			} else if button.tag == (colorTitle.count - 1) {
				// 맨 마지막
				vColorOption.addConstraint(NSLayoutConstraint(item: button,
															 attribute: .trailing,
															 relatedBy: .equal,
															 toItem: vColorOption,
															 attribute: .trailing,
															 multiplier: 1,
															 constant: 0))
			}
			
			if let priviousItem = vColorOption.viewWithTag(button.tag - 1) as? UIButton {
				vColorOption.addConstraint(NSLayoutConstraint(item: button,
															 attribute: .leading,
															 relatedBy: .equal,
															 toItem: priviousItem,
															 attribute: .trailing,
															 multiplier: 1,
															 constant: 0))
			}
			
			button.addConstraint(NSLayoutConstraint(item: button,
													attribute: .width,
													relatedBy: .equal,
													toItem: nil,
													attribute: .notAnAttribute,
													multiplier: 1,
													constant: 60))
			
			
			vColorOption.addConstraint(NSLayoutConstraint(item: button,
														 attribute: .top,
														 relatedBy: .equal,
														 toItem: vColorOption,
														 attribute: .top,
														 multiplier: 1,
														 constant: 0))
			
			vColorOption.addConstraint(NSLayoutConstraint(item: button,
														 attribute: .bottom,
														 relatedBy: .equal,
														 toItem: vColorOption,
														 attribute: .bottom,
														 multiplier: 1,
														 constant: 0))
		})
		
		let pinch = UIPinchGestureRecognizer(target: self, action: #selector(viewDidPinch))
		vContainer.addGestureRecognizer(pinch)
	}
	
	// 뒤로
	@IBAction func onBackDidTouchUpInside(_ sender: UIButton) {
		navigationController?.popViewController(animated: true)
	}
	
	// 사진 정렬
	@IBAction func onBtnAlignDidTouchUpInside(_ sender: UIButton) {
		guard selectedIvImage != nil else {
			return
		}
		
		seletedSubMenuIndex = seletedSubMenuIndex == 1 ? -1 : 1
		
		vColorOption.removeFromSuperview()
		svScrollview.addSubview(vAlignOption)
		
		vAlignOption.frame = CGRect(x: 0, y: 0, width: 60*alignTitle.count, height: 60)
		svScrollview.contentSize = CGSize(width: 60*alignTitle.count, height: 60)
	}
	
	// 정렬 서브 옵션
	@objc private func onBtnAlignOptionDidTouch(sender: UIButton) {
		let align = alignTitle[sender.tag]
		
		guard let selectIv = selectedIvImage else {
			return
		}

		var xPosition = selectIv.frame.origin.x
		var yPosition = selectIv.frame.origin.y

		switch align {
		case .middle:
			//정가운데
			xPosition = vContainer.frame.midX - selectIv.frame.size.width / 2
			yPosition = vContainer.frame.midY - selectIv.frame.size.height / 2
		case .xmiddle:
			// x의 중심
			xPosition = vContainer.frame.midX - selectIv.frame.size.width / 2
		case .ymiddle:
			// y의 중심
			yPosition = vContainer.frame.midY - selectIv.frame.size.height / 2
		case .top:
			// 상단에 맞추기
			yPosition = 0
		case .bottom:
			// 하단에 맞추기
			yPosition = vContainer.frame.maxY - selectIv.frame.height
		case .right:
			// 오른쪽 정렬
			xPosition = vContainer.frame.maxX - selectIv.frame.width
		case .left:
			// 왼쪽 정렬
			xPosition = 0
		}

		UIView.animate(withDuration: 0.2,
					   animations: {
						selectIv.frame.origin.x = xPosition
						selectIv.frame.origin.y = yPosition
		})
	}
	
	// 배경색메뉴 터치시 서브 메뉴 보여짐
	@IBAction func onBtnColorDidTouch(_ sender: UIButton) {
		seletedSubMenuIndex = seletedSubMenuIndex == 2 ? -1 : 2
		
		vAlignOption.removeFromSuperview()
		svScrollview.addSubview(vColorOption)
		
		vColorOption.frame = CGRect(x: 0, y: 0, width: 60*colorTitle.count, height: 60)
		svScrollview.contentSize = CGSize(width: 60*colorTitle.count, height: 60)
	}
	
	// 배경색 서브메뉴 터치시 배경 변경
	@objc private func onBtnColorOptionDidTouch(sender: UIButton) {
		let color = colorTitle[sender.tag]
		switch color {
		case .black: // 검정
			vBackground.backgroundColor = .black
		case .white: // 흰색
			vBackground.backgroundColor = .white
		case .pink: // 진핑크
			vBackground.backgroundColor = UIColor().hexColor("#eb9f9f")
		case .lightpink: // 연핑크
			vBackground.backgroundColor = UIColor().hexColor("#f1bbba")
		case .lightpurple: // 연보라
			vBackground.backgroundColor = UIColor().hexColor("#D7ACF6")
		case .lightgray: // 밝은회색
			vBackground.backgroundColor = UIColor().hexColor("#B7D7D9")
		default:
			vBackground.backgroundColor = .clear
			//기타 colorpicker
		}
	}
	
	// 핀치 제스쳐(확대 축소)
	@objc private func viewDidPinch(gesture: UIPinchGestureRecognizer) {
		guard let iv = selectedIvImage else {
			return
		}
		
		switch gesture.state {
		case .began:
			isPinching = true
			
			guard imageLastScale[iv] == nil else {
				return
			}
			imageLastScale[iv] = 1.0
		case .changed:
			isPinching = true
			if let lastScale = imageLastScale[iv] {
				let minScale: CGFloat = 0.05
				var newScale = lastScale + (gesture.scale - 1.0) //1.0 - (lastScale - gesture.scale)
				newScale = newScale < minScale ? minScale : newScale
				
				UIView.animate(withDuration: 0.2,
							   animations: {
								iv.transform = CGAffineTransform(scaleX: newScale, y: newScale)
				})
			}
		case .ended:
			
			imageLastScale[iv] = iv.transform.a
			isPinching = false
		default: break
		}
	}
	
	// 사진 저장
	@IBAction private func userWillSavePhoto(_ sender: UIButton) {
		selectedIvImage?.layer.borderColor = UIColor.clear.cgColor
		
		let image = UIImage(view: vContainer)
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
		
		selectedIvImage?.layer.borderColor = UIColor.blue.cgColor
	}
	
	// 앨범 저장 콜백
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// we got back an error!
			let ac = UIAlertController(title: "저장 에러 ^ㅠ^", message: error.localizedDescription, preferredStyle: .alert)
			ac.addAction(UIAlertAction(title: "확인", style: .default))
			present(ac, animated: true)
		} else {
			let finishVC = FinishVC(nibName: "FinishVC", bundle: Bundle.main)
			finishVC.image = image

			self.navigationController?.pushViewController(finishVC, animated: true)
		}
	}
	
	// 네비게이션이 보여짐
	private func navigationbarWillHidden() {
		UIView.animate(withDuration: 0.3,
					   animations: {
						self.vNavigationBar.alpha = 0
						self.vBottomBar.alpha = 0
		},
					   completion: { _ in
						self.vNavigationBar.isHidden = true
						self.vBottomBar.isHidden = true
		})
	}
	
	// 네비게이션이 사라짐
	private func navigationbarWillShow() {
		vNavigationBar.isHidden = false
		vBottomBar.isHidden = false
		
		UIView.animate(withDuration: 0.3,
					   animations: {
						self.vNavigationBar.alpha = 1
						self.vBottomBar.alpha = 1
		})
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		guard let touch = touches.first,
			let touchView = touch.view else {
			return
		}
		
		// 컨테이너 뷰를 터치시 상단 하단 바가 사라짐
		guard touchView == vBackground else {
			// 이미지 뷰를 터치시 해당 이미지 뷰 셀렉 상태
			if touchView is UIImageView, let touchIv = touchView as? UIImageView {
				selectedIvImage = touchIv
				seletedPriviousMovePoint = touch.location(in: touchView)
			}
			return
		}
		
		selectedIvImage = nil
		seletedPriviousMovePoint = nil
		isNavigationHidden = !isNavigationHidden
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		// 이미지 뷰 중심 이동
		guard !isPinching,
			let touch = touches.first,
			let touchView = touch.view,
			let iv = selectedIvImage,
			touchView == iv,
			let seletedPriviousMovePoint = seletedPriviousMovePoint,
			seletedPriviousMovePoint != touch.location(in: touchView) else {
			return
		}
		
		let selectedCurrentMovePoint = touch.location(in: touchView)
		
		let xMovement = selectedCurrentMovePoint.x - seletedPriviousMovePoint.x
		let yMovement = selectedCurrentMovePoint.y - seletedPriviousMovePoint.y
		
		var ivOrigin = CGPoint()
		ivOrigin.x = iv.frame.origin.x + xMovement
		ivOrigin.y = iv.frame.origin.y + yMovement

		UIView.animate(withDuration: 0.1,
					   animations: {
						self.selectedIvImage?.frame.origin = ivOrigin
		})
	}
}
