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
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var videoSlider: UISlider!
    
    @IBOutlet weak var volumeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backwardBtn: UIButton!
    
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
    
    @IBAction func clickOnSearchBtn(_ sender: Any) {
        
        guard textField.text != "" else {
            return
        }
        guard textField.text == "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4" else {
            
            if let count = videoView.layer.sublayers?.count {
                
               if count > 1 {
                    layer?.removeFromSuperlayer()
                }
            }
            return
        }
        
        let remoteURL = NSURL(string: "https://s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")
        self.player = AVPlayer(url: remoteURL! as URL)
        layer = AVPlayerLayer(player: self.player)
        
        layer?.frame = videoView.bounds
        videoView.layer.addSublayer(layer!)

        player?.play()
        playBtn.setImage(ImageAsset.stop.imageTemplate, for: .normal)
        
        addTimeObserver()
        addPeriodicTimeObserver()

    }
    
    @IBAction func fullScreenBtnTapped(_ sender: Any) {
        
        switch UIDevice.current.orientation.isPortrait {
        case true:
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            
        case false:
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            
        }
        changeOrientation()
    }
}

extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()

        changeOrientation()
        
        makeImageTemplate()
        makeblackBtn()
        
        hideKeyboard()
        
        videoSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: .touchDown)
    }
    
    @objc func sliderValueChanged(slider: UISlider) {
        
        player?.seek(to: CMTime(seconds: Double(slider.value), preferredTimescale: 1))
//        timeLabel.text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layer?.frame = videoView.bounds
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        changeOrientation()
    
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

        volumeBtn.setImage(ImageAsset.volume_up.imageTemplate, for: .normal)

    }
    
    func turnOffSound(){
      
        player?.volume = 0.0

        volumeBtn.setImage(ImageAsset.volume_off.imageTemplate, for: .normal)
        
    }
    
    func play() {
        
        changePlayingTime(sliderValue: videoSlider.value)
        
        playBtn.setImage(ImageAsset.stop.imageTemplate, for: .normal)

    }
    
    func pause() {
        
        player?.pause()
    
        playBtn.setImage(ImageAsset.play_button.imageTemplate, for: .normal)

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
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            // update player transport UI
            self?.videoSlider.value = Float(time.seconds)
            self?.currentTime.time = Int(time.second)
           
            
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
        
        playBtn.setImage(ImageAsset.stop.imageTemplate, for: .normal)
        
    }
    
    func changeOrientation() {
        
        if UIDevice.current.orientation.isLandscape {
            navigationController?.navigationBar.isHidden = true
            textField.isHidden = true
            searchBtn.isHidden = true
            fullScreenBtn.setImage(ImageAsset.full_screen_exit.imageTemplate, for: .normal)
            timeLabel.textColor = UIColor.white
            endTimeLabel.textColor = UIColor.white
            makeWhiteBtn()
            
        } else {
            navigationController?.navigationBar.isHidden = false
            textField.isHidden = false
            searchBtn.isHidden = false
            fullScreenBtn.setImage(ImageAsset.full_screen_button.imageTemplate, for: .normal)
            timeLabel.textColor = UIColor.black
            endTimeLabel.textColor = UIColor.black
            makeblackBtn()
        }
    }
    
    func makeImageTemplate() {
        playBtn.setImage(ImageAsset.play_button.imageTemplate, for: .normal)
        volumeBtn.setImage(ImageAsset.volume_up.imageTemplate, for: .normal)
        forwardBtn.setImage(ImageAsset.fast_forward.imageTemplate, for: .normal)
        backwardBtn.setImage(ImageAsset.rewind.imageTemplate, for: .normal)
        fullScreenBtn.setImage(ImageAsset.full_screen_button.imageTemplate, for: .normal)
       
    }
    
    func makeblackBtn() {
        playBtn.tintColor = UIColor.black
        volumeBtn.tintColor = UIColor.black
        forwardBtn.tintColor = UIColor.black
        backwardBtn.tintColor = UIColor.black
        fullScreenBtn.tintColor = UIColor.black
    }
    
    func makeWhiteBtn() {
        playBtn.tintColor = UIColor.white
        volumeBtn.tintColor = UIColor.white
        forwardBtn.tintColor = UIColor.white
        backwardBtn.tintColor = UIColor.white
        fullScreenBtn.tintColor = UIColor.white
    }
}

extension UIViewController
{
    func hideKeyboard() {
    
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
