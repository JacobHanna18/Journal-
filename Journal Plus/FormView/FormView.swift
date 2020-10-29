//
//  FormView.swift
//  FormView
//
//  Created by Jacob Hanna on 30/09/2020.
//

import SwiftUI

struct CellsView : View{
    
    var props : FormProperties
    
    var body: some View{
        
        ZStack{
            ScrollView {
                VStack {
                    ForEach(props.cells) { cell  in
                        cell.padding(.horizontal).padding(.vertical,8)
                        if cell.divider{
                            Divider()
                        }
                    }
                    
                }
            }
        }
        
    }
}

struct FormView: View {
    
    var props : FormProperties
    
    var dismiss : (()->Void)? = nil
    
    
    @State var showAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        
        ZStack{
            //Color(UIColor.systemBackground).ignoresSafeArea(.all)
            mainView
        }
        
    }
    
    var mainView: some View {
        NavigationView{
        VStack{
            CellsView(props: props)
            
            
            HStack {
                Spacer()
                
                if let label = props.doneButton.label{
                    Button(action: {
                        props.done?()
                        dismiss?()
                        
                        
                    }) {
                        Text(label)
                    }.frame(maxWidth: .infinity)
                    .padding(.all)
                    
                    Spacer()
                }

                
                
                
                if let label = props.button.label{
                    Button(action: {
                        if(props.button.showAlert){
                            showAlert = true
                        }else{
                            props.delete?()
                            dismiss?()
                        }
                        
                    }) {
                        Text(label)
                            .accentColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/)
                    }.frame(maxWidth: .infinity)
                    .padding(.all)
                    Spacer()
                }
                
            }
        }.alert(isPresented: $showAlert, content: {
            Alert(
                title: Text("Are you sure?"),
                message: Text("This cannot be undone."),
                primaryButton: .destructive(Text("Yes"), action: {
                    props.delete?()
                    dismiss?()
                }),
                secondaryButton: .cancel(Text("No"), action: {
                    showAlert = false
                })
            )
        }).navigationBarTitle(Text(props.title ?? "PropTitle Error"))
    }
    }
    
}


let StringTitleTemp = FormCell(type: .StringTitle(), title: "DemoTitle", tap: {
    print("tap")
})

let StringSub1Temp = FormCell(type: .StringSub1, title: "Test Title", get: { () -> Any in
    return "test subtitle 1"
}, tap: {
    print("tap")
})
let StringSub2Test = FormCell(type: .StringSub2, title: "Test Title", get: { () -> Any in
    return "test subtitle 2"
}, tap: {
    print("tap")
})
let StringInTemp = FormCell(type: .StringInput, title: "Test Title", set: { (str) in
    if let st = str as? String{
        testStringInput = st;
        print(testStringInput)
    }
}, get: { () -> Any in
    print("get")
    return testStringInput
}, tap: {
    print("tap")
})
let DoubleInTemp = FormCell(type: .DoubleInput, title: "Test Title", set: { (str) in
    if let st = str as? Double{
        testDoubleInput = st;
        print(testDoubleInput)
    }
}, get: { () -> Any in
    return testDoubleInput
}, tap: {
    print("tap")
})
let IntInTemp = FormCell(type: .IntInput, title: "Test Title", set: { (str) in
    if let st = str as? Int{
        testIntInput = st;
        print(testIntInput)
    }
}, get: { () -> Any in
    print("get")
    return testIntInput
}, tap: {
    print("tap")
})
let IntSubTemp = FormCell(type: .IntSub, title: "Test Title", get: { () -> Any in
    return testIntInput
}, tap: {
    print("tap")
})
let DoubleSubTemp = FormCell(type: .DoubleSub, title: "Test Title", get: { () -> Any in
    return testDoubleInput
}, tap: {
    print("tap")
})
let ColorInTemp = FormCell(type: .ColorInput, title: "test title", set: { (color) in
    if let co = color as? Color{
        print(co.description)
        testColorInput = co
    }
}, get: { () -> Any in
    return testColorInput
}, tap: {
    print("tap")
})
let DateInTemp = FormCell(type: .DateInput(showTime: true, showDate: false), title: "test title", set: { (color) in
    if let co = color as? Date{
        print(co.description)
        testDateInput = co
    }
}, get: { () -> Any in
    return testDateInput
}, tap: {
    print("tap")
})
let BoolInTemp = FormCell(type: .BoolInput(), title: "Test Title", set: { (str) in
    if let st = str as? Bool{
        testBoolInput = st;
        print(testBoolInput)
    }
}, get: { () -> Any in
    print("get")
    return testBoolInput
}, tap: {
    print("tap")
})
let SingleSelectionTemp = FormCell(type: .SingleSelection(labels: ["label1","label2"]), title: "test title", set: { (ind) in
    if let i = ind as? Int{
        print(i)
    }
}, get: { () -> Any in
    return testSingleSelectionInput
}, tap: {
    print("tap")
})

let LongStringInTemp =  FormCell(type: .LongStringInput(height: 100), title: "Test Title", set: { (str) in
    if let st = str as? String{
        testStringInput = st;
        print(testStringInput)
    }
}, get: { () -> Any in
    print("get")
    return testStringInput
}, tap: {
    print("tap")
})


struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView(props: FormProperties(title: "TestTitle", done: {
            print("done")
        }, delete: {
            print("delete")
        }, dismiss: {
            print("dismiss")
        }, cells: [
            StringTitleTemp,StringSub1Temp,StringSub2Test,StringInTemp,DoubleInTemp,IntInTemp,IntSubTemp,DoubleSubTemp,ColorInTemp,DateInTemp,BoolInTemp,SingleSelectionTemp,LongStringInTemp
        ]))
    }
}
