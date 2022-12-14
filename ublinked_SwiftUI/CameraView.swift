//
//  CameraView.swift
//  ublinked_SwiftUI
//
//  Created by 한태희 on 2022/10/10.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @State var isLoading: Bool = true
    @ObservedObject var viewModel = CameraViewModel()
    @State var progressValue: Float = 0.0
    @State var imgArr : [UIImage] = []
    
    var body: some View {
        ZStack {
            viewModel.cameraPreview.ignoresSafeArea()
                .onAppear {
                viewModel.configure()
            }
            
            ZStack(alignment: .center) {
                Text("\(viewModel.picCount) / \(viewModel.model.numPictures)")
                    .bold()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 8.0)
                        .foregroundColor(Color.red)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(CGFloat(viewModel.picCount) / CGFloat(viewModel.model.numPictures)))
                        .stroke(style: StrokeStyle(lineWidth: 8.0, lineCap: .round, lineJoin: .round))
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)
                }
                .frame(width: 50.0,height: 50.0)
            }
            .opacity(Double(viewModel.model.progressViewOpacity))
            .animation(.linear)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)
                HStack(spacing: 0) {
                    // numPictures 변경
                    Button(action: {viewModel.changeNumPictures()}) {
                        Image("Pictures"+String(viewModel.model.numPictures))
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    // 플래시 온오프
                    Button(action: {viewModel.switchSilent()}) {
                        Image(systemName: viewModel.isSilentModeOn ?
                              "bolt.fill" : "bolt")
                            .foregroundColor(viewModel.isSilentModeOn ? .yellow : .white)
                            .frame(width: 25, height: 25)
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    Button(action: {viewModel.changeCamera()}) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .frame(width: 25, height: 25)
                        
                    }
                    .padding(.horizontal, 25)
                }
                .font(.system(size:25))
                .padding()
                
                Spacer()
                
                ZStack(alignment: .bottom){
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.5)
                        .frame(height: 140)
//
                    HStack(alignment: .center){
                        // 찍은 사진 미리보기, 일단 액션 X
                        Button(action: {}) {
                            if let previewImage = viewModel.recentImage {
                                Image(uiImage: previewImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Rectangle())
                                    .aspectRatio(1, contentMode: .fit)
                                    .padding(15)
                            } else {
                                Rectangle()
                                    .stroke(lineWidth: 2)
                                    .frame(width: 50, height: 50)
                                    .padding(15)
                            }
                        }.opacity(0.0)
                        
                        Spacer()
                        
                        // 사진찍기 버튼
                        ZStack{
                            Circle()
                                .stroke(lineWidth: 5)
                                .frame(width: 65, height: 65)
                                .padding()
                            
                            Button(action: {
                                viewModel.picCountSync()
                                viewModel.capturePhoto()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 55, height: 55)
                                    .padding(15)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Rectangle()
                                .stroke(lineWidth: 2)
                                .frame(width: 50, height: 50)
                                .padding(15)
                                .opacity(0)
                        }
                    }
                    .padding(30)
                }
            }
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.all)
            
            // Launch Screen
            if isLoading {
                launchScreenView.transition(.opacity).zIndex(1)
            }
            
        }.onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                withAnimation { isLoading.toggle() }
            })
        }
        .opacity(viewModel.shutterEffect ? 0 : 1)
    }
    
}

struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
             AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
   
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        view.videoPreviewLayer.session = session
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoOrientation = .portrait

        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}

extension CameraView {
    
    var launchScreenView: some View {
        
        ZStack(alignment: .center) {
            
            LinearGradient(gradient: Gradient(colors: [Color("PrimaryColor"), Color("SubPrimaryColor")]),
                            startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
            
            Image("uBlinked_launchScreen")
            
        }
        
    }
    
}
