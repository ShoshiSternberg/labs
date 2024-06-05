include "../util/number.dfy"
include "../util/maps.dfy"
include "../util/tx.dfy"
include "./fixed.dfy"


module Lending{

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

  constructor(totalD:u256, totalB:u256){
    baseRate:=20000000000000000;
    fixedAnnualBorrowRate:=300000000000000000;
    totalDeposited:=totalD;
    totalBorrowd:=totalB;

  }


  method calculateBorrowFee(amount:u256) returns(fee:u256) {
    var borrowRate:=borrowRate();
    assume {:axiom} (amount as nat) * (borrowRate as nat) <= MAX_U256 as nat;
    fee:= Mul(amount,borrowRate);
    assume{:axiom} (amount as nat) - (fee as nat) >= 0 as nat;

  }

  method borrowRate()returns(r:u256){
    var uRatio:= utilizationRatio();
    var interestMultiplier:= interestMultiplier();
    assume {:axiom} (uRatio as nat) *(interestMultiplier as nat) <= MAX_U256 as nat;
    assume {:axiom} ((uRatio as nat) *(interestMultiplier as nat) as nat) +(baseRate as nat) <= MAX_U256 as nat;
    r:=Add(Mul(uRatio,interestMultiplier),baseRate);

  }

  method utilizationRatio() returns(r:u256){
    assume {:axiom} (totalBorrowd as nat) *(totalDeposited as nat) <= MAX_U256 as nat;
    r:=Mul(totalBorrowd,totalDeposited);
  }

  method interestMultiplier()returns(r:u256){
    var uRatio := utilizationRatio();
    assume{:axiom} (fixedAnnualBorrowRate as nat) - (baseRate as nat) >= 0 as nat;
    var num:=Sub(fixedAnnualBorrowRate,baseRate);
    assume {:axiom} (num as nat) *(uRatio as nat) <= MAX_U256 as nat;
    r:=Mul(num,uRatio);
  }

  method getExp(a: u256, b: u256) returns (r: u256)
    requires b != 0
  {
    assume {:axiom} (a as nat) *(WAD as nat) <= MAX_U256 as nat;
    var scaledNumber := Mul(a, WAD);    
    r := Fixed.Div(scaledNumber, b);
  }
}
}

import opened Lending
  method {:test} testCalculateBorrowFee() {

    var lendingProtocol:=new LendingProtocol(100,100);

    var fee:u256;
    var paid:u256;
    fee:=lendingProtocol.calculateBorrowFee(100);
    //assert fee==6;
    print(fee);

    var x:=lendingProtocol.getExp(10,4);
    var scaledNumber := Mul(10, Pow(10, 18) as u256);    
    var r := Fixed.Div(scaledNumber, 4);
    //assert x ==r;
    
    
  }