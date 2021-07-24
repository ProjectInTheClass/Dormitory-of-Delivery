// 함수를 "1급 객체" 즉, 어디든지 사용할수 있다
import UIKit

// addVAT와 couponDiscount함수는 매개변수와 리턴형태가 같으므로 같은 함수타입이다
// finalPrice함수의 매개변수에 함수를 받았다. additional의 매개변수에는 addVAT와 couponDiscount가 들어갈수 있다.
// 이때 addVAT는 함수를 호출하는것이 아닌 함수자체를 객체로 본 것이다.
func addVAT(source:Double) -> Double {
    return source * 1.1
}

func couponDiscount(source:Double) -> Double{
    return source * 0.9
}

func finalPrice(source:Double, additional:(Double)->Double) -> Double{
    let price = additional(source)
    return price
}

let transaction1 = finalPrice(source: 38.4, additional: addVAT)


 
// 함수를 리턴하는 변수
// makeAdder의 반환값은 (Int를 받아서 Int를 반환하는 함수)를 반환하게된다. 이러한기능을 "커링"이라한다. 만약, 어떠한 함수의 매개변수가 10개라고한다면 10개의 변수를 다받기전까지 기능을 못하지만 매개변수가 하나라도 결정되면 바로바로 실행할수있게 하는 효율적인 코드를 짤수있게 도와준다.
func makeAdder(x:Int) -> (Int) -> Int {
    func adder(a:Int) -> Int{
        return x + a
    }
    return adder
}

let add5 = makeAdder(x: 5)
let add10 = makeAdder(x: 10)
print(add5(2))
print(add10(2))
print(makeAdder(x: 5)(2))


//
func sayHello(){
    print("Hello")
}

let fn1: ()->() = sayHello
let fn2: ()->Void = sayHello

fn1()
fn2()



// fn3의 타입은 함수, fn3를 사용할려면 함수 호출
func makeDouble(value: Int) -> Int {
    return value * 2
}

let fn3: (Int) -> Int = makeDouble
let ret = fn3(10)



// (Int, Double) -> Int
// [String] -> Int
// (String,Int) -> [String: Int]인 함수만들기
func function(_ :Int , _ :Double) -> Double {
    return 0.0
}

func function1(_ : [String]) -> Int {
    return 0
}

func function2(_ str: String, _ int: Int) -> [String: Int]{
    var dictionary: [String: Int] = [:]
    dictionary[str] = int
    return dictionary
}
