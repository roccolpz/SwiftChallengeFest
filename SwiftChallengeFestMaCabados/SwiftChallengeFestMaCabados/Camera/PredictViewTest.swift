import SwiftUI
import CoreML

struct PredictViewTest: View {
    
    @State var viewModel = ViewModel()
    @State var text = "Take a photo!"
    @State var image: UIImage?
    
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
        CameraView(image: $viewModel.currentFrame)
            .rotationEffect(.degrees(90))
        
        Image(uiImage: image ?? UIImage(systemName: "xmark")!)
        
        Text(text)
        
        Button("Take Photo") {
            predictImage()
        }
    }
    
    func predictImage() {
        print("Taking photo...")
        guard let cgImage = viewModel.currentFrame else {
            print("No image available to send")
            return
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
            image = resizedImage.rotated90DegreesClockwise()
        }catch {
            print("error!")
        }
    }
}

#Preview {
    PredictViewTest()
}
