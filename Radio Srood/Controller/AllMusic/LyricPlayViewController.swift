//
//  LyricPlayViewController.swift
//  Radio Srood
//
//  Created by Tech on 25/05/2023.
//  Copyright © 2023 Appteve. All rights reserved.
//

import UIKit
import CoreMedia
import SpotlightLyrics

class LyricPlayViewController: UIViewController {
        
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var lblNameSong: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var lyricsView: LyricsView!
    var currentSong = SongModel()
    var timeObserver: Any?
    var lyricsUrl = ""
    private let totalDuration = player?.currentItem?.duration
        
        override func viewDidLoad() {
            super.viewDidLoad()
            lblNameSong.text = currentSong.track
            if let url = URL(string: currentSong.artcover) {
                imgSong.af_setImage(withURL: url, placeholderImage: UIImage(named: "Lav_Radio_Logo.png"))
            }
            let data = (try? Data(contentsOf: URL(string: lyricsUrl)!))!
            let lyrics = String(data: data, encoding: .utf8)
            lyricsView.lyrics = lyrics
            lyricsView.backgroundColor = .clear
            lyricsView.lyricFont = UIFont.boldSystemFont(ofSize: 24)
            lyricsView.lyricTextColor = UIColor.lightGray
            lyricsView.lyricHighlightedFont = UIFont.boldSystemFont(ofSize: 24)//systemFont(ofSize: 18)
            lyricsView.lyricHighlightedTextColor = UIColor.white
            if  player?.isPlaying ?? false{
                play()
            }
            else{
                stop()
            }
            self.playerSlider.minimumValue = 0.0
            self.playerSlider.maximumValue = Float(player?.currentItem?.asset.duration.seconds ?? 0.0)
            populateLabelWithTime(self.lblStartTime, time: 0.0)
            populateLabelWithTime(self.lblEndTime, time: player?.currentItem?.asset.duration.seconds ?? 0.0)
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            //time observer to update slider.
            timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), // used to monitor the current play time and update slider
                                           queue: DispatchQueue.global(), using: { [weak self] (progressTime) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.playerSlider.value = Float(progressTime.seconds)
                    self.populateLabelWithTime(self.lblStartTime, time: progressTime.seconds)
                }
            })
            
            if !(player?.isPlaying ?? false){
                self.btnPlay.setImage(UIImage(named: "ic_play"), for: .normal)
            
            } else {
                self.btnPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
            }
            
        }
    
    @IBAction func actionPlay(_ sender: Any) {
        if (player?.isPlaying ?? false){
            player?.pause()
            stop()
            self.btnPlay.setImage(UIImage(named: "ic_play"), for: .normal)
           
        } else {
            player?.play()
            play()
            self.btnPlay.setImage(UIImage(named: "ic_pause"), for: .normal)
        }
    }
    @IBAction func progressSliderValueChanged() {
        let seconds: Int64 = Int64(playerSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player?.seek(to: targetTime)
        if let player = player{
            lyricsView.timer.seek(toTime: player.currentTime().seconds)
        }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        playerSlider.setValue(0, animated: true)
        populateLabelWithTime(self.lblStartTime, time: 0.0)
        player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func populateLabelWithTime(_ label : UILabel, time: Double) {
        let minutes = Int(time / 60)
        let seconds = Int(time) - minutes * 60
        label.text = String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
        
    @IBAction func actiONdONE(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
        private func play() {
            if let player = player{
                lyricsView.timer.seek(toTime: player.currentTime().seconds)
                lyricsView.timer.play()
            }
        }
        
        private func stop() {
            lyricsView.timer.pause()
        }
        

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    }

