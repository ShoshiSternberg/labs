include "../util/number.dfy"
include "../util/maps.dfy"
include "../util/tx.dfy"


import opened Number
import opened Maps
import opened Tx


class MathClass{

  const EXP_SCALE :nat:=  Pow(10, 18)
  const HALF_EXP_SCALE:nat:= EXP_SCALE/2

//   method getExp(num:nat,denom:nat) returns(r:nat)
//     requires denom>0
//     requires num> denom
//     ensures r ==  if num*EXP_SCALE % denom ==0 then (num*EXP_SCALE)/denom else 0{
//         var a:=num*EXP_SCALE;
//         if a/num==EXP_SCALE {r:= Div(num*EXP_SCALE,denom);}
//         else {r:=0;}
//   }

// method getExp(num: nat, denom: nat) returns (r: nat)
//     requires denom > 0
//     requires num > denom
//     ensures r == if num * EXP_SCALE % denom == 0 then (num * EXP_SCALE) / denom else 0
// {
//     var a := num * EXP_SCALE;
//     if a % denom == 0 {
//         r := a / denom;
//     } else {
//         r := Div(num*EXP_SCALE,denom);
//     }
// }

method getExp(num: nat, denom: nat) returns (r: nat)
    requires denom > 0
    requires num > denom
    ensures r == num * EXP_SCALE / denom
{
    var a := num * EXP_SCALE;
    r := a / denom;
}


}