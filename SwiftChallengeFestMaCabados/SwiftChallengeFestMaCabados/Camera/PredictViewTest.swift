import SwiftUI
import CoreML

struct PredictViewTest: View {
    
    @State var viewModel = ViewModel()
    @State var text = "Take a photo!"
    @State var showResultSheet = false
    @State var result = PredictionResult(isValid: false, label: "", confidence: 0)
    let uiscreen = UIScreen.main
    
    let model: SeeFood = {
        do {
            let config = MLModelConfiguration()
            return try SeeFood(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create SeeFood")
        }
    }()
    
    var body: some View {
        ZStack{
            CameraView(image: $viewModel.currentFrame)
            
                .frame(width:uiscreen.bounds.width, height: uiscreen.bounds.height)
            
            VStack {
                Spacer()
                
                Button {
                    result = predictImage()
                    showResultSheet = true
                } label: {
                    HStack {
                        Text("Tomar Foto")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 50)
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 32)
                    }
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .padding(.bottom, 30)
                
            }
            .ignoresSafeArea()
            .sheet(isPresented: $showResultSheet) {
                ResultSheet(result: result)
            }
        }
    }
    
    func predictImage() -> PredictionResult {
        print("Taking photo...")
        guard let cgImage = viewModel.currentFrame else {
            print("No image available to send")
            return PredictionResult(isValid: false, label: "", confidence: 0)
        }
        
        let uiImage = UIImage(cgImage: cgImage)
        let resizedImage = uiImage.resized(to: CGSize(width: 299, height: 299))
        let rotatedImage : UIImage = resizedImage.rotated90DegreesClockwise() ?? UIImage(systemName: "xmark")!
        
        do {
            let actualResult: SeeFoodOutput
            try actualResult = model.prediction(image: rotatedImage.convertToBuffer() ?? UIImage(systemName: "xmark")!.convertToBuffer()!)
            
            let confidence = actualResult.foodConfidence[actualResult.classLabel] ?? 0.0
            print("Prediction: \(actualResult.classLabel)")
            text = "\(actualResult.classLabel) \(confidence)"
            
            
            if (confidence > 0.8) {
                return PredictionResult(isValid: true, label: actualResult.classLabel, confidence: confidence)
            } else {
                return PredictionResult(isValid: false, label: "", confidence: 0)
            }
            
        }catch {
            print("error!")
            return PredictionResult(isValid: false, label: "", confidence: 0)
        }
    }
}

#Preview {
    PredictViewTest()
}
