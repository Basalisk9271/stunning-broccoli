//
//  ContentView.swift
//  HelloWorld
//
//  Created by Gabe Imlay on 2/1/23.
//

import SwiftUI
import OpenAISwift

final class ViewModel: ObservableObject{
    init(){
        
    }
    
    private var client: OpenAISwift?
    
    func setup(){
        client = OpenAISwift(authToken: "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")
    }
    
    func send(text: String,
              completion: @escaping(String) -> Void){
        client?.sendCompletion(with: text, maxTokens: 500, completionHandler: {result in
            switch result{
            case .success(let model):
                let output = model.choices.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
        
        
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var models = [String]()
    
    var body: some View {
        ScrollView{
            
            VStack (alignment: .leading) {
                ForEach(models, id: \.self) { string in
                    Text(string)
                }
                
                Spacer()
                
                HStack{
                    TextField("Type here...", text: $text)
                    Button("Send"){
                        send()
                    }
                }
            }
        }
        .onAppear{
            viewModel.setup()
        }
        .padding()
    }
    
    func send(){
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        models.append("\nMe: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                self.models.append("\nChatGPT: "+response)
                self.text = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
