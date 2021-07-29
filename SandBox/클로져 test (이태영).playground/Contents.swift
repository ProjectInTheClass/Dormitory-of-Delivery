//import UIKit
//
//func changeDoubleValueAndAdd(num1: Int, num2: Double) -> Int {
//    return num1 + Int(num2)
//}
//
//let fn1: (Int, Double) -> Int = changeDoubleValueAndAdd
//
//fn1(1, 2.5)
//
//
//let fn1WithClosure: (Int, Double) -> Int = {(num1: Int, num2: Double) -> Int in return num1 + Int(num2)
//}
//
//fn1WithClosure(1, 2.5)
//
//func arrayCount(array1: [String]) -> Int {
//    return array1.count
//}
//
//let fn2: ([String]) -> Int = arrayCount
//
//let aaaaa: [String] = ["하나", "둘", "셋", "넷"]
//
//fn2(aaaaa)
//
//let arrayCountWithClosure: ([String]) -> Int = {
//    (array1: [String]) -> Int in return array1.count
//}
//arrayCountWithClosure(aaaaa)
//
//
//func makeDictionary(key: String, value: Int) -> [String:Int] {
//    var myDictionary: [String:Int] = [:]
//    myDictionary[key] = value
//    return myDictionary
//}
//
//let fn3: (String, Int) -> [String: Int] = makeDictionary
//
//var aaa = fn3("하나", 1)
//
//print(aaa)
//
//let makeDictionaryWithClosure:(String, Int) -> [String: Int] = { (key: String, value: Int) -> [String:Int] in var myDictionary: [String:Int] = [:]
//  myDictionary[key] = value
//return myDictionary
//}
//
//var aaa = makeDictionaryWithClosure("하나", 1)
//print(aaa)
//
//func sayHi2(handler: (String) -> Void) {
//    handler("Hi")
//}
//
//sayHi2(handler: {arg in print(arg)})
//
//func justDoIt(what: () -> ()) {
//    what()
//}
//let fn: () -> () = { () -> () in print("fn works")}
//
//justDoIt(what: fn)
//
//justDoIt {
//    print("fn2 works")
//}
//
//func addTwoNums(_ arg1: Int, _ arg2: Int, handler: (Int) -> Void) {
//    handler(arg1 + arg2)
//}
//
//addTwoNums(1, 2) {ret in print("1 + 2 = \(ret)")
//
//}


//map, fliter, reduce

//let array = [1, 3, 4, 2, 5]

//array.map{(item: Int) -> String in return "\(item * 2)"}
//print(array)

//array.filter{(item: Int) -> Bool in return (item % 2) != 0}
//print(array)

//let resultReduce = array.reduce(""){(prevRet: String, item: Int) -> String in return prevRet + "\(item)"
//}
//print(resultReduce)




//array.filter{(item) -> Bool in return item > 3}
//array.map{(item) -> Int in return item * 2}
//print(array)
//let reduceArray = array.reduce(0){(prevRet: Int, item: Int) -> Int in return prevRet + item}
//
//print(reduceArray)

// 121416 만들기
let array = [1, 2, 3, 4, 5, 6, 7, 8]

//var newArray: [Int] = []
//var newArray2: [Int] = []
//var result: String = ""
//
//for item in array {
//    if item > 5 {
//        newArray.append(item)
//    }
//}
//
//for item in newArray {
//    newArray2.append(item * 2)
//}
//
//for item in newArray2 {
//    result += "\(item)"
//}
//
//print(result)

//let result = array.filter{ (item: Int) -> Bool in return item > 5}.map{ (item: Int) -> Int in return item * 2}.reduce(""){ (prevRet: String, item: Int) -> String in return prevRet + "\(item)"}
//
//print(result)


