//
//  image.swift
//  ASiC Midterm-Exam
//
//  Created by 蔡佳宣 on 2019/3/29.
//  Copyright © 2019年 蔡佳宣. All rights reserved.
//

import UIKit

enum ImageAsset: String {
    
    case fast_forward
    case full_screen_button
    case full_screen_exit
    case play_button
    case rewind
    case stop
    case volume_off
    case volume_up
    
}

extension UIImage {
    
    static func asset(_ asset: ImageAsset) -> UIImage? {
        
        return UIImage(named: asset.rawValue)
    }
    
}
