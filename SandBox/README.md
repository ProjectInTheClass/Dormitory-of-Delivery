# 샌드박스 테스트

+ 갱신이 되나요?
+ 이거요?
+ hello
이번에는 앞에 +를 쓰지 않겠습니다




//1 부터 31까지의 날짜 중, 1의자리 수에 3이 들어간 날짜를 모두 골라주세요
var three: [Int] = []
for item in 1...31 {
    if item % 10 == 3 {
        three.append(item)
    }
}
print("3이 들어간 날짜는 바로바로", three)



// 1부터 20까지의 수 중에서 4의 배수를 모아보시오
var four: [Int] = []
for item in 1...20 {
    if item % 4 == 0 {
        four.append(item)
    }
}
print("4의 배수는 :", four)
