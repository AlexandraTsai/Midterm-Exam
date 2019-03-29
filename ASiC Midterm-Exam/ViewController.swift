//
//  ViewController.swift
//  ASiC Midterm-Exam
//
//  Created by 蔡佳宣 on 2019/3/29.
//  Copyright © 2019年 蔡佳宣. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var player: AVPlayer?
    
    var layer: AVPlayerLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let remoteURL = NSURL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")
        self.player = AVPlayer(url: remoteURL! as URL)
        layer = AVPlayerLayer(player: self.player)
        
        videoView.layer.addSublayer(layer!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer?.frame = videoView.bounds
        
    }
    
    @IBAction func clickOnPlayBtn(_ sender: Any) {
        
        switch player?.rate {
        case 0.0:
            play()
        default:
            pause()
        }
        
    }
    
    
    @IBAction func volumnButtonTapped(_ sender: Any) {
       
        switch player?.volume {
        case 0.0:
            turnUpSound()
        default:
            turnOffSound()
        }
        
    }
    
}

extension ViewController {
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 63/255, green: 81/255, blue: 181/255, alpha: 1)
        
        self.navigationController?.navigationBar.barStyle = .black
    }
    
    //Volume
    func turnUpSound() {
        
       
        player?.volume = 1.0
        volumeBtn.setImage(UIImage.asset(.volume_up), for: .normal)
       
        print("********TURN UP***************")
        print("Volume \(player?.volume)")
        print("Rate \(player?.rate)")
    }
    
    func turnOffSound(){
      
        player?.volume = 0.0
        volumeBtn.setImage(UIImage.asset(.volume_off), for: .normal)
       
        print("-------- TURN OFF ------------")
        print("Volume \(player?.volume)")
        print("Rate \(player?.rate)")
    }
    
    func play() {
        player?.play()
        playBtn.setImage(UIImage.asset(.stop), for: .normal)
        print("***********************")
        print("Volume \(player?.volume)")
        print("Rate \(player?.rate)")
    }
    
    func pause() {
        player?.pause()
        playBtn.setImage(UIImage.asset(.play_button), for: .normal)
        print("***********************")
        print("Volume \(player?.volume)")
        print("Rate \(player?.rate)")    }
    
}

