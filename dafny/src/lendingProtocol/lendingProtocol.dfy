include "../util/number.dfy"
include "../util/maps.dfy"
include "../util/tx.dfy"
include "./fixed.dfy"


import opened Number
import opened Maps
import opened Tx
import opened Fixed


class LendingProtocol{

  const EXP_SCALE :nat:=  Pow(10, 18)
  const HALF_EXP_SCALE:nat:= EXP_SCALE/2

  var baseRate:u256
  var totalBorrowd:u256
  var totalDeposited:u256
  var fixedAnnualBorrowRate:u256

  constructor(){
    baseRate:=20000000000000000;
    fixedAnnualBorrowRate:=300000000000000000;

  }


  method calculateBorrowFee(amount:u256) returns(fee:u256,paid:u256) {
    var borrowRate:=borrowRate();
    fee:= Mul(amount,borrowRate);
    paid:= Sub(amount,fee);
  }

  method borrowRate()returns(r:u256){
    var uRatio:= utilizationRatio();
    var interestMultiplier:= interestMultiplier();
    r:=Add(Mul(uRatio,interestMultiplier),baseRate);

  }

  method utilizationRatio() returns(r:u256){
    r:=Mul(totalBorrowd,totalDeposited);
  }

  method interestMultiplier()returns(r:u256){
    var uRatio := utilizationRatio();
    var num:=Sub(fixedAnnualBorrowRate,baseRate);
    r:=Mul(num,uRatio);
  }

  method getExp(a: u256, b: u256) returns (r: u256)
    requires b != 0
  {
    var scaledNumber := Mul(a, WAD);
    r := Div(scaledNumber, b);
  }





}