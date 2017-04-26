//
//  AvdioTool.swift
//  NN
//
//  Created by 郑东喜 on 2017/4/25.
//  Copyright © 2017年 郑东喜. All rights reserved.
//  录音工具

import UIKit
import AVFoundation

class AvdioTool: NSObject {
    var audioRecorder: AVAudioRecorder? // 录音
    var audioPlayer: AVAudioPlayer? // 播放
    
    
    fileprivate var mp3Path: String?
    fileprivate var cafPath: String?
    fileprivate var amrPath: String?

    fileprivate var player: AVAudioPlayer?
    
    var voiceData : Data?
    
    static let shared = AvdioTool()
    
    
    let recordSettings = [
        AVSampleRateKey : NSNumber(value: Float(4000)),
        
        AVNumberOfChannelsKey : NSNumber(value: Int32(1)),
        AVEncoderAudioQualityKey :
            NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]
    

    
    func directoryURL() -> URL? {
        // 定义并构建一个url来保存音频
        cafPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        mp3Path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        amrPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
//        mp3Path?.append("/temp.mp3")
        mp3Path?.append("/temp.wav")
        cafPath?.append("/temp.wav")
        amrPath?.append("/temp.amr")
        
        return URL(fileURLWithPath: cafPath!)
    }
    
    
    // 创建会话
    func creatSession()
    {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            if let url: URL = self.directoryURL() {
                try audioRecorder = AVAudioRecorder(url: url, settings:recordSettings) // 初始化实例
            }
            audioRecorder?.prepareToRecord() // 准备录音
        } catch {
            
        }
    
    
    }
    
    /// playAudio
    fileprivate func playAudio() -> Void {
        if let isRecording = audioRecorder?.isRecording {
            if (!isRecording)
            {
                do {
                    if let url = audioRecorder?.url {
                        try audioPlayer = AVAudioPlayer(contentsOf: url)
                    }
                    audioPlayer?.play()
                    print("playCaf!")
                } catch {
                    
                }
            }
        }
    
    }
    
    /// 转换wav
    func convertWavToAmr() -> Void {
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",cafPath as Any)
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",amrPath as Any)
        
        VoiceConverter.convertWav(toAmr: cafPath, amrSavePath: amrPath)
        
//        do {
//            let amrData = try Data.init(contentsOf: URL.init(string: cafPath!)!)
//            print("\((#file as NSString).lastPathComponent):(\(#line))\n",amrData)
//        } catch {
//            print("\((#file as NSString).lastPathComponent):(\(#line))\n",error.localizedDescription)
//        }
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",cafPath as Any)

        voiceData = FileManager.default.contents(atPath: mp3Path!)
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",voiceData!)
        
//        let amrData = WavConvert.readSoundFileSamples(mp3Path)
        
//        voiceData = amrPath
        
        print("\((#file as NSString).lastPathComponent):(\(#line))\n",amrPath as Any)
    
        print(cafPath!)
        print(mp3Path!)
    }

    /// 开始录音
    func startRecord() -> Void {
        if let isRecording: Bool = audioRecorder?.isRecording {
            if !isRecording {
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setActive(true)
                    audioRecorder?.record()
                    print("recordCaf!")
                } catch {
                    
                }
            }
        }
    }
    
    func stopRecord() -> Void {
        audioRecorder?.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
            print("stopCaf!")
        } catch {
            
        }
    }
    
    /// 开始播放
    func startPlaying() -> Void {
        if let isRecording = audioRecorder?.isRecording {
            if (!isRecording)
            {
                do {
                    if let url = audioRecorder?.url {
                        try audioPlayer = AVAudioPlayer(contentsOf: url)
                        
                        
                    }
                    audioPlayer?.play()
                    print("playCaf!")
                } catch {
                    
                }
            }
        }
    }
    
    /// 暂停播放
    func pushPlaying() -> Void {
        if let isRecording = audioRecorder?.isRecording {
            if !isRecording {
                do {
                    if let url = audioRecorder?.url {
                        try audioPlayer = AVAudioPlayer(contentsOf: url)
                    }
                    audioPlayer?.pause()
                    print("pauseCaf")
                } catch {
                    
                }
            }
        }
    }
    
    /// 转换MP3
    func toMP3() {
//        let audioWrapper: AudioWrapper = AudioWrapper()
//        
//        audioWrapper.convertSourcem4a(cafPath, outPutFilePath: mp3Path) { (a:String?) in
//            print("end \(String(describing: a))");
//        }
//        print(cafPath!)
//        print(mp3Path!)
//        print("toMp3")
    }
    
    /// 播放MP3
    func playMp3()
    {
        do {
            self.player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: self.mp3Path!), fileTypeHint: "mp3")
        } catch {
            print("出现异常")
        }
        player?.play()
        print("playMp3")
    }
}
