//
//  ViewController.swift
//  ASiC Midterm-Exam
//
//  Created by 蔡佳宣 on 2019/3/29.
//  Copyright © 2019年 蔡佳宣. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia

class ViewController: UIViewController {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var player: AVPlayer?
    
    var layer: AVPlayerLayer?
    
    var currentTime = VideoTime()

    var observation: NSKeyValueObservation?
    
    var playerItem: AVPlayerItem!
    var timeObserverToken: Any?
    
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
    
    @IBAction func videoSliderChange(_ slider: UISlider) {
        
        let seconds : Int64 = Int64(slider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
    }
    
    
    @IBAction func fastForwardBtnTapped(_ sender: Any) {
        
        videoSlider.value += 10.0
        changePlayingTime(sliderValue: videoSlider.value)
    }
    @IBAction func backwardBtnTapped(_ sender: Any) {
        
        videoSlider.value -= 10.0
        changePlayingTime(sliderValue: videoSlider.value)
    }
    
}

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        let remoteURL = NSURL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")
        self.player = AVPlayer(url: remoteURL! as URL)
        layer = AVPlayerLayer(player: self.player)
        
        videoView.layer.addSublayer(layer!)
        
        addTimeObserver()
        addPeriodicTimeObserver()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer?.frame = videoView.bounds
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
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
    
    }
    
    func turnOffSound(){
      
        player?.volume = 0.0
        volumeBtn.setImage(UIImage.asset(.volume_off), for: .normal)

    }
    
    func play() {
        
        changePlayingTime(sliderValue: videoSlider.value)
        playBtn.setImage(UIImage.asset(.stop), for: .normal)
   
    }
    
    func pause() {
        player?.pause()
        playBtn.setImage(UIImage.asset(.play_button), for: .normal)
    }
    
    func addTimeObserver(){
        
        self.observation = currentTime.observe(\.time, options: .new, changeHandler: { (time, change) in
            guard let newValue = change.newValue, let minute = self.player?.currentTime().minute else {
                return
            }
            if newValue >= 10 {
                self.timeLabel.text = "\(minute):\(newValue)"
            } else {
                self.timeLabel.text = "\(minute):0\(newValue)"
            }
            
            
        })
    }
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            
            guard let currentTime = self?.player?.currentTime().second else {
                return
            }
            
            self?.currentTime.time = currentTime
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    func changePlayingTime(sliderValue: Float) {
        
        let seconds : Int64 = Int64(sliderValue)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        player?.play()
        
    }
}

