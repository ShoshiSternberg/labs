use debug::PrintTrait;
fn main(){
    //variables
    let immutible_var: felt252=17;
    
    let mut mutable_var: felt252=immutible_var;
    mutable_var=38;

    assert(mutable_var!=immutible_var,'mutable equals immutable');
    mutable_var.print();
    
    //functions
    let x=3;
    let mut a= inc(:x);
    a.print();

    //if expression
    let is_awesome=true;
    if is_awesome{
        let c='Cairo is awesome!';
        c.print();
    }

    let f=3618502788666131213697322783095070105623107215331596699973092056135872020470;
    let a=2/f;
    
    assert (f==-11,' i  dont understand');
}

fn inc(x:u32)-> u32{
    
    return x+1;
}

#[test]
fn test_main(){
    main();

}